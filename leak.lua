-- ============================================================
-- HUY PHAM HUB | menu: Skyro UI | code: leak.lua
-- ============================================================
if _G.HuyPhamHub then
  pcall(function() _G.HuyPhamHub.destroy() end)
  _G.HuyPhamHub = nil
end

-- ============================================================
-- HUY PHAM HUB — PHẦN 1/4
-- Services + Helper + USSI + Leak + Copy helpers
-- ============================================================
local httpService = game:GetService("HttpService")
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local starterPack = game:GetService("StarterPack")
local starterGui = game:GetService("StarterGui")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local marketplaceService = game:GetService("MarketplaceService")
local tweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")
local localPlayer = players.LocalPlayer

if coreGui:FindFirstChild("HuyPham_UI") then
  coreGui.HuyPham_UI:Destroy()
end

-- ============================================================
-- HELPER: LƯU FILE LEAK
-- ============================================================
local function getDownloadPaths()
  local paths = {}
  local username = nil
  pcall(function()
    if getgenv and getgenv().USERNAME then username = getgenv().USERNAME end
  end)
  if not username then
    pcall(function() username = game:GetService("Players").LocalPlayer.Name end)
  end
  if username then
    table.insert(paths, "C:/Users/" .. username .. "/Downloads/")
    table.insert(paths, "C:\\Users\\" .. username .. "\\Downloads\\")
  end
  table.insert(paths, "C:/Users/Public/Downloads/")
  table.insert(paths, "D:/Downloads/")
  table.insert(paths, "")
  return paths
end

local function saveLeakFile(fileName, content)
  local paths = getDownloadPaths()
  for _, basePath in ipairs(paths) do
    local fullPath = basePath .. fileName
    local ok = pcall(function() writefile(fullPath, content) end)
    if ok and isfile and isfile(fullPath) then
      return true, fullPath, (basePath == "" and "Workspace executor" or "Downloads")
    end
  end
  return false, nil, nil
end

local function findLeakFile(fileName)
  local candidates = {
    fileName, fileName .. ".rbxlx", fileName .. ".rbxl",
    fileName:gsub("%.rbxlx$", ""), fileName:gsub("%.rbxlx$", "") .. ".rbxl",
    fileName:gsub("%.rbxlx$", "") .. ".rbxmx", fileName:gsub("%.rbxlx$", "") .. ".rbxm",
  }
  for _, name in ipairs(candidates) do
    if isfile and isfile(name) then return name end
  end
  return nil
end

-- ============================================================
-- USSI
-- ============================================================
local USSI_URL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau"
local cachedUSSI = nil

local function getUSSI()
  if cachedUSSI then return cachedUSSI end
  if not game.HttpGet then return nil, "Executor không hỗ trợ HttpGet" end
  local ok, code = pcall(function() return game:HttpGet(USSI_URL, true) end)
  if not ok or not code or #code < 100 then return nil, "Không tải được USSI" end
  local fn, err = loadstring(code, "USSI")
  if not fn then return nil, "Load USSI thất bại" end
  local ok2, ussi = pcall(fn)
  if not ok2 then return nil, "Chạy USSI thất bại" end
  if type(ussi) == "function" then
    cachedUSSI = ussi
    return ussi
  elseif type(ussi) == "table" and type(ussi.SaveInstance) == "function" then
    cachedUSSI = ussi.SaveInstance
    return cachedUSSI
  end
  return nil, "USSI không hợp lệ"
end

-- ============================================================
-- LEAK LOGIC AN TOÀN
-- ============================================================
local GameName = "FullGame"
pcall(function()
  local n = marketplaceService:GetProductInfo(game.PlaceId).Name
  if n then GameName = n:gsub("%W", "") end
end)

local SERVICE_NAMES = {
  "Workspace", "ReplicatedStorage", "ReplicatedFirst", "ServerStorage", "ServerScriptService",
  "StarterGui", "StarterPack", "StarterPlayer", "Lighting", "Teams", "SoundService", "Chat",
  "MarketplaceService", "Players", "JointsService", "Debris", "LocalizationService", "TestService",
  "InsertService", "HttpService", "TextService", "ContentProvider", "LogService", "ScriptContext",
  "GuiService", "VRService", "ContextActionService", "PathfindingService", "PhysicsService",
  "ProximityPromptService", "TweenService", "CollectionService", "GroupService", "TeleportService",
  "BadgeService", "UserInputService", "RunService", "TouchInputService", "NetworkClient",
  "CookiesService", "PolicyService", "KeyframeSequenceProvider", "AnalyticsService",
  "MemoryStoreService", "DataStoreService", "MessagingService", "AssetService",
  "AvatarEditorService", "FaceAnimatorService", "MaterialService", "PlayerEmulatorService",
  "AppStorageService", "ControllerService", "RbxAnalyticsService", "StylingService",
  "TextChatService", "VoiceChatService", "SharedTableRegistry", "VisualizationModeService",
  "GeometryService",
}

local allServices = {}
for _, name in ipairs(SERVICE_NAMES) do
  local ok, svc = pcall(function() return game:GetService(name) end)
  if ok and svc then table.insert(allServices, svc) end
end

local function forceArchivable(root, depth, visited)
  depth = depth or 0
  visited = visited or {}
  if depth > 30 then return 0 end
  local count = 0
  local ok, children = pcall(function() return root:GetChildren() end)
  if not ok or not children then return 0 end
  for _, child in ipairs(children) do
    if not visited[child] then
      visited[child] = true
      pcall(function()
        if child.Archivable == false then
          child.Archivable = true
          count = count + 1
        end
      end)
      count = count + forceArchivable(child, depth + 1, visited)
    end
  end
  return count
end

local function streamAllMap()
  local streamed = false
  pcall(function()
    if workspace.StreamingEnabled then
      workspace.StreamingEnabled = false
      streamed = true
    end
  end)
  if not streamed then
    pcall(function()
      if workspace.StreamingEnabled then
        local cam = workspace.CurrentCamera
        local center = cam and cam.CFrame.Position or Vector3.new(0, 0, 0)
        for r = 0, 4096, 256 do
          for angle = 0, math.pi * 2, math.pi / 8 do
            local pos = center + Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
            pcall(function() workspace:RequestStreamAroundAsync(pos, 0.5) end)
          end
        end
      end
    end)
  end
  task.wait(1.5)
end

local function preProcess()
  streamAllMap()
  local total = 0
  for _, svc in ipairs(allServices) do
    local ok, c = pcall(function() return forceArchivable(svc) end)
    if ok and c then total = total + c end
  end
  task.wait(0.5)
end

local function safeLeak(kind)
  local saveMethod = rawget(getfenv(), "saveinstance") or (getgenv and getgenv().saveinstance)
  local ussi, ussiErr = getUSSI()
  if not saveMethod and not ussi then
    return false, "Executor không hỗ trợ leak. Hãy dùng PC executor (Solara/Wave)."
  end
  local isMobile = false
  pcall(function()
    isMobile = userInputService.TouchEnabled and not userInputService.KeyboardEnabled
  end)
  if isMobile and not saveMethod then
    return false, "Mobile executor không có saveinstance. Cần PC executor để leak script."
  end
  local okPre, errPre = pcall(preProcess)
  if not okPre then return false, "Pre-process lỗi: " .. tostring(errPre) end
  local FileName
  if kind == "model" then
    FileName = "MODEL_ONLY_" .. GameName .. "_" .. game.PlaceId .. ".rbxlx"
  else
    FileName = "FULL_LEAK_" .. GameName .. "_" .. game.PlaceId .. ".rbxlx"
  end
  local options
  if kind == "model" then
    options = {
      mode = "optimized", noscripts = true, decompile = false, timeout = 15000,
      filename = FileName, extraInstances = { workspace },
      SaveTerrain = true, SaveCamera = true, SaveLighting = true,
      IsolateLocalPlayer = true, IgnoreLocalPlayer = true, IgnoreLocalCharacter = true,
    }
  else
    options = {
      mode = "full", noscripts = false, decompile = true, decompileTimeout = 30,
      timeout = 120000, filename = FileName, extraInstances = allServices,
      SavePlayers = true, IsolatePlayers = false, IsolateLocalPlayer = true,
      IgnoreLocalPlayer = true, IgnoreLocalCharacter = true,
      SaveTerrain = true, SaveCamera = true, SaveLighting = true,
      IgnoreHidden = false, IgnoreNotArchivable = false, IncludeNil = true,
    }
  end
  local execOk, execErr
  if ussi then execOk, execErr = pcall(function() ussi(options) end) end
  if not execOk and saveMethod then execOk, execErr = pcall(function() saveMethod(options) end) end
  if not execOk then return false, "Leak thất bại: " .. tostring(execErr) end
  local actualFile = findLeakFile(FileName:gsub("%.rbxlx$", ""))
  if not actualFile then return true, FileName .. " (đã tạo nhưng không tìm thấy)" end
  local content = readfile(actualFile)
  if not content or #content == 0 then return false, "File rỗng" end
  local saved, finalPath = saveLeakFile(FileName, content)
  if saved then return true, finalPath end
  return true, actualFile .. " (chỉ lưu workspace)"
end

-- ============================================================
-- SERIALIZE
-- ============================================================
local function f1(p1)
  local v1 = typeof(p1)
  if v1 == "boolean" or v1 == "string" or v1 == "number" then return p1
  elseif v1 == "UDim2" then return { T = "UDim2", XS = p1.X.Scale, XO = p1.X.Offset, YS = p1.Y.Scale, YO = p1.Y.Offset }
  elseif v1 == "UDim" then return { T = "UDim", S = p1.Scale, O = p1.Offset }
  elseif v1 == "Vector3" then return { T = "Vector3", X = p1.X, Y = p1.Y, Z = p1.Z }
  elseif v1 == "Vector2" then return { T = "Vector2", X = p1.X, Y = p1.Y }
  elseif v1 == "Color3" then return { T = "Color3", R = p1.R, G = p1.G, B = p1.B }
  elseif v1 == "CFrame" then return { T = "CFrame", C = { p1:GetComponents() } }
  elseif v1 == "Rect" then return { T = "Rect", MiX = p1.Min.X, MiY = p1.Min.Y, MaX = p1.Max.X, MaY = p1.Max.Y }
  elseif v1 == "EnumItem" then return { T = "Enum", ET = tostring(p1.EnumType), EV = p1.Name }
  elseif v1 == "ColorSequence" then
    local v2 = {}
    for _, v in ipairs(p1.Keypoints) do
      table.insert(v2, { Ti = v.Time, R = v.Value.R, G = v.Value.G, B = v.Value.B })
    end
    return { T = "ColorSequence", K = v2 }
  elseif v1 == "NumberSequence" then
    local v3 = {}
    for _, v in ipairs(p1.Keypoints) do
      table.insert(v3, { Ti = v.Time, V = v.Value, E = v.Envelope })
    end
    return { T = "NumberSequence", K = v3 }
  end
  if v1 == "NumberRange" then return { T = "NumberRange", Mi = p1.Min, Ma = p1.Max } end
  return nil
end

local function f2()
  if isfile and isfile("HuyPham_GuiConfig.json") then
    local ok, v = pcall(function() return httpService:JSONDecode(readfile("HuyPham_GuiConfig.json")) end)
    if ok and type(v) == "table" then return v end
  end
  return { Scale = 1, CustomSizeX = 380, CustomSizeY = 420 }
end

local function f3(cfg)
  if writefile then
    pcall(function() writefile("HuyPham_GuiConfig.json", httpService:JSONEncode(cfg)) end)
  end
end

local v6 = f2()

local function f4(p3, p4, p5, p6)
  if p6 == 1 then return p5 end
  if p4 == "Size" and p3:IsA("BasePart") then return Vector3.new(p5.X * p6, p5.Y * p6, p5.Z * p6) end
  if p4 == "CFrame" and p3:IsA("BasePart") then
    local v7 = { p5:GetComponents() }
    local v8 = p5.Position * p6
    return CFrame.new(v8.X, v8.Y, v8.Z, v7[4], v7[5], v7[6], v7[7], v7[8], v7[9], v7[10], v7[11], v7[12])
  end
  if p4 == "Scale" and p3:IsA("SpecialMesh") then return Vector3.new(p5.X * p6, p5.Y * p6, p5.Z * p6) end
  return p5
end

local v9 = {
  BasePart = { "Name", "Anchored", "CanCollide", "CanTouch", "CastShadow", "Locked", "Transparency", "Reflectance", "Color", "Material", "MaterialVariant", "Shape", "Size", "Position", "Orientation", "CFrame", "Massless" },
  MeshPart = { "MeshId", "TextureID", "MeshType", "RenderFidelity", "CollisionFidelity" },
  Mesh = { "MeshId", "TextureId", "MeshType", "Scale", "Offset", "VertexColor" },
  Decal = { "Texture", "Color3", "Transparency", "Face", "ZIndex" },
  Texture = { "Texture", "Color3", "Transparency", "Face", "StudsPerTileU", "StudsPerTileV", "OffsetStudsU", "OffsetStudsV" },
  Sound = { "SoundId", "Volume", "PlaybackSpeed", "Pitch", "Looped", "Playing", "RollOffMaxDistance", "RollOffMinDistance", "RollOffMode", "TimePosition" },
  Tool = { "ManualActivationOnly", "RequiresHandle", "ToolTip", "Grip", "GripPos", "GripForward", "GripRight", "GripUp" },
  ParticleEmitter = { "Texture", "Rate", "Speed", "Lifetime", "Size", "Color", "Transparency", "LightEmission", "LightInfluence", "Acceleration", "Drag", "LockedToPart", "EmissionDirection", "Enabled", "RotSpeed", "Rotation", "SpreadAngle", "VelocityInheritance", "ZOffset" },
  Fire = { "Enabled", "Color", "SecondaryColor", "Heat", "Size" },
  Smoke = { "Enabled", "Color", "Opacity", "RiseVelocity", "Size" },
  Sparkles = { "Enabled", "Color", "SparkleColor" },
  Beam = { "Texture", "Color", "Transparency", "LightEmission", "LightInfluence", "Width0", "Width1", "CurveSize0", "CurveSize1", "TextureLength", "TextureSpeed", "TextureMode", "Enabled", "Segments", "FaceCamera", "ZOffset" },
  Trail = { "Texture", "Color", "Transparency", "LightEmission", "LightInfluence", "Lifetime", "MinLength", "MaxLength", "Width0", "Width1", "TextureLength", "TextureMode", "FaceCamera", "Enabled" },
  Light = { "Enabled", "Brightness", "Color", "Range", "Shadows", "Angle", "Face" },
  Lighting = { "Brightness", "ClockTime", "FogColor", "FogEnd", "FogStart", "GeographicLatitude", "OutdoorAmbient", "Ambient", "ExposureCompensation", "ShadowSoftness", "GlobalShadows" },
  Atmosphere = { "Density", "Offset", "Color", "Decay", "Glare", "Haze" },
  Sky = { "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "StarCount", "SunTextureId", "MoonTextureId", "CelestialBodiesShown" },
  Clouds = { "Cover", "Density", "Color" },
  PostEffect = { "Enabled", "Intensity", "Size", "Threshold", "Brightness", "Contrast", "Saturation", "TintColor", "FarIntensity", "NearIntensity", "FocusDistance", "InFocusRadius", "Spread" },
  GuiBase = { "Visible", "ZIndex", "LayoutOrder", "Active", "Draggable", "ClipsDescendants", "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "BorderSizePixel", "Position", "Size", "Rotation", "SizeConstraint", "AutomaticSize", "AnchorPoint" },
  TextGui = { "Text", "TextColor3", "Font", "TextSize", "TextScaled", "TextWrapped", "TextXAlignment", "TextYAlignment", "RichText", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "LineHeight", "PlaceholderText", "PlaceholderColor3" },
  ImageGui = { "Image", "ImageColor3", "ImageTransparency", "ImageRectOffset", "ImageRectSize", "ScaleType", "SliceCenter", "SliceScale", "TileSize" },
  ScrollingFrame = { "CanvasSize", "CanvasPosition", "ScrollBarThickness", "ScrollBarImageColor3", "ScrollBarImageTransparency", "ScrollingEnabled", "ScrollingDirection" },
  UIModifier = { "CornerRadius", "Color", "Thickness", "Transparency", "ApplyStrokeMode", "LineJoinMode", "Enabled", "PaddingTop", "PaddingBottom", "PaddingLeft", "PaddingRight", "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder", "CellSize", "CellPadding", "AspectRatio" },
  UIGradient = { "Rotation", "Enabled", "Offset" },
  BillboardGui = { "AlwaysOnTop", "MaxDistance", "Size", "SizeOffset", "StudsPerOffsetV", "StudsPerOffsetU", "Enabled", "Active", "ClipsDescendants", "LightInfluence", "ZIndexBehavior" },
  SurfaceGui = { "Face", "Enabled", "Active", "ClipsDescendants", "PixelsPerStud", "ToolPunchThroughDistance", "ZIndexBehavior", "LightInfluence", "SizingMode" },
  ScreenGui = { "ScreenInsets", "DisplayOrder", "ZIndexBehavior", "Enabled", "ResetOnSpawn", "IgnoreGuiInset" },
  ProximityPrompt = { "ActionText", "ObjectText", "HoldDuration", "MaxActivationDistance", "RequiresLineOfSight", "Enabled", "Style" },
  Constraint = { "Enabled", "C0", "C1", "CurrentAngle", "TargetAngle", "LimitsEnabled", "LowerAngle", "UpperAngle", "Restitution", "Stiffness", "Damping" },
  Weld = { "Enabled", "C0", "C1" },
  Humanoid = { "WalkSpeed", "JumpPower", "JumpHeight", "MaxHealth", "Health", "NameDisplayDistance", "HealthDisplayDistance", "HipHeight", "AutoRotate" },
  Script = { "Disabled", "RunContext" },
}

local function f5(p7)
  local v10, v11 = {}, {}
  local function f6(list)
    for _, n in ipairs(list) do
      if not v11[n] then v11[n] = true; table.insert(v10, n) end
    end
  end
  f6({ "Name" })
  if p7:IsA("BasePart") then f6(v9.BasePart) end
  if p7:IsA("MeshPart") then f6(v9.MeshPart) end
  if p7:IsA("SpecialMesh") or p7:IsA("BlockMesh") or p7:IsA("CylinderMesh") then f6(v9.Mesh) end
  if p7:IsA("Decal") then f6(v9.Decal) end
  if p7:IsA("Texture") then f6(v9.Texture) end
  if p7:IsA("Sound") then f6(v9.Sound) end
  if p7:IsA("Tool") then f6(v9.Tool) end
  if p7:IsA("ParticleEmitter") then f6(v9.ParticleEmitter) end
  if p7:IsA("Fire") then f6(v9.Fire) end
  if p7:IsA("Smoke") then f6(v9.Smoke) end
  if p7:IsA("Sparkles") then f6(v9.Sparkles) end
  if p7:IsA("Beam") then f6(v9.Beam) end
  if p7:IsA("Trail") then f6(v9.Trail) end
  if p7:IsA("Light") then f6(v9.Light) end
  if p7.ClassName == "Lighting" then f6(v9.Lighting) end
  if p7:IsA("Atmosphere") then f6(v9.Atmosphere) end
  if p7:IsA("Sky") then f6(v9.Sky) end
  if p7:IsA("Clouds") then f6(v9.Clouds) end
  if p7:IsA("PostEffect") then f6(v9.PostEffect) end
  if p7:IsA("GuiObject") or p7:IsA("GuiBase2d") then f6(v9.GuiBase) end
  if p7:IsA("TextLabel") or p7:IsA("TextButton") or p7:IsA("TextBox") then f6(v9.TextGui) end
  if p7:IsA("ImageLabel") or p7:IsA("ImageButton") then f6(v9.ImageGui) end
  if p7:IsA("ScrollingFrame") then f6(v9.ScrollingFrame) end
  if p7:IsA("UICorner") or p7:IsA("UIStroke") or p7:IsA("UIPadding") or p7:IsA("UIListLayout") or p7:IsA("UIGridLayout") or p7:IsA("UIAspectRatioConstraint") then f6(v9.UIModifier) end
  if p7:IsA("UIGradient") then f6(v9.UIGradient) end
  if p7:IsA("BillboardGui") then f6(v9.BillboardGui) end
  if p7:IsA("SurfaceGui") then f6(v9.SurfaceGui) end
  if p7:IsA("ScreenGui") then f6(v9.ScreenGui) end
  if p7:IsA("ProximityPrompt") then f6(v9.ProximityPrompt) end
  if p7:IsA("Weld") or p7:IsA("WeldConstraint") or p7:IsA("Motor6D") or p7:IsA("ManualWeld") then f6(v9.Weld) end
  if p7:IsA("Constraint") or p7:IsA("JointInstance") then f6(v9.Constraint) end
  if p7:IsA("Humanoid") then f6(v9.Humanoid) end
  if p7:IsA("Script") or p7:IsA("LocalScript") or p7:IsA("ModuleScript") then f6(v9.Script) end
  return v10
end

local function f7(p9)
  if not p9 then return nil end
  local ok, cls = pcall(function() return p9.ClassName end)
  if not ok then return nil end
  local v12 = { Cls = cls, Name = p9.Name, P = {}, Ch = {} }
  if p9:IsA("Weld") or p9:IsA("WeldConstraint") or p9:IsA("Motor6D") or p9:IsA("ManualWeld") then
    pcall(function()
      if p9.Part0 then v12.P._Part0Name = p9.Part0.Name end
      if p9.Part1 then v12.P._Part1Name = p9.Part1.Name end
    end)
  end
  if p9:IsA("LocalScript") or p9:IsA("ModuleScript") then
    pcall(function()
      if decompile then v12.P._ScriptSource = decompile(p9)
      elseif getscriptbytecode then v12.P._ScriptSource = "-- Bytecode --\n" .. getscriptbytecode(p9) end
    end)
  end
  if p9:IsA("UIGradient") then
    pcall(function()
      v12.P.Rotation = p9.Rotation
      v12.P.Enabled = p9.Enabled
      v12.P.Offset = f1(p9.Offset)
      local cs = {}
      for _, k in ipairs(p9.Color.Keypoints) do
        table.insert(cs, { Ti = k.Time, R = k.Value.R, G = k.Value.G, B = k.Value.B })
      end
      v12.P._ColorSeq = cs
      local ts = {}
      for _, k in ipairs(p9.Transparency.Keypoints) do
        table.insert(ts, { Ti = k.Time, V = k.Value, E = k.Envelope })
      end
      v12.P._TransSeq = ts
    end)
  else
    for _, prop in ipairs(f5(p9)) do
      pcall(function()
        local val = p9[prop]
        if val ~= nil then
          local s = f1(val)
          if s ~= nil then v12.P[prop] = s end
        end
      end)
    end
  end
  for _, ch in ipairs(p9:GetChildren()) do
    if ch.Name ~= "HuyPham_UI" then
      local c = f7(ch)
      if c then table.insert(v12.Ch, c) end
    end
  end
  return v12
end

local function f8(p10)
  if type(p10) ~= "table" or not p10.T then return p10 end
  local t = p10.T
  if t == "UDim2" then return UDim2.new(p10.XS, p10.XO, p10.YS, p10.YO)
  elseif t == "UDim" then return UDim.new(p10.S, p10.O)
  elseif t == "Vector3" then return Vector3.new(p10.X, p10.Y, p10.Z)
  elseif t == "Vector2" then return Vector2.new(p10.X, p10.Y)
  elseif t == "Color3" then return Color3.new(p10.R, p10.G, p10.B)
  elseif t == "CFrame" then return CFrame.new(unpack(p10.C))
  elseif t == "Rect" then return Rect.new(p10.MiX, p10.MiY, p10.MaX, p10.MaY)
  elseif t == "Enum" then
    local ok, e = pcall(function() return Enum[p10.ET][p10.EV] end)
    if ok and e then return e end
    return nil
  elseif t == "ColorSequence" then
    local arr = {}
    for _, v in ipairs(p10.K) do
      table.insert(arr, ColorSequenceKeypoint.new(v.Ti, Color3.new(v.R, v.G, v.B)))
    end
    return ColorSequence.new(arr)
  elseif t == "NumberSequence" then
    local arr = {}
    for _, v in ipairs(p10.K) do
      table.insert(arr, NumberSequenceKeypoint.new(v.Ti, v.V, v.E or 0))
    end
    return NumberSequence.new(arr)
  elseif t == "NumberRange" then return NumberRange.new(p10.Mi, p10.Ma) end
  return nil
end

local function f9(p11, p12, p13)
  task.defer(function()
    task.wait(0.1)
    if not p11 or not p11.Parent then return end
    local model = p11:FindFirstAncestorOfClass("Model") or p11:FindFirstAncestorOfClass("Folder") or p11.Parent
    if model then
      if p12 and not p11.Part0 then p11.Part0 = model:FindFirstChild(p12, true) or p11.Parent end
      if p13 and not p11.Part1 then p11.Part1 = model:FindFirstChild(p13, true) end
    end
  end)
end

local function f10(p14, p15)
  local v24 = p15 or 1
  local ok, inst = pcall(function() return Instance.new(p14.Cls) end)
  if not ok or not inst then return nil end
  pcall(function() inst.Name = p14.Name end)
  if p14.Cls == "UIGradient" then
    pcall(function()
      if p14.P.Rotation then inst.Rotation = p14.P.Rotation end
      if p14.P.Enabled ~= nil then inst.Enabled = p14.P.Enabled end
      if p14.P.Offset then inst.Offset = f8(p14.P.Offset) end
      if p14.P._ColorSeq then
        local arr = {}
        for _, v in ipairs(p14.P._ColorSeq) do
          table.insert(arr, ColorSequenceKeypoint.new(v.Ti, Color3.new(v.R, v.G, v.B)))
        end
        inst.Color = ColorSequence.new(arr)
      end
      if p14.P._TransSeq then
        local arr = {}
        for _, v in ipairs(p14.P._TransSeq) do
          table.insert(arr, NumberSequenceKeypoint.new(v.Ti, v.V, v.E or 0))
        end
        inst.Transparency = NumberSequence.new(arr)
      end
    end)
  else
    for k, v in pairs(p14.P) do
      if k:sub(1, 1) ~= "_" then
        pcall(function()
          local cv = f8(v)
          if cv ~= nil then inst[k] = f4(inst, k, cv, v24) end
        end)
      end
    end
  end
  if inst:IsA("LocalScript") or inst:IsA("ModuleScript") then
    local id = Instance.new("NumberValue")
    id.Name = "_ScriptSourceID"
    id.Value = math.random(100000, 999999)
    id.Parent = inst
    if p14.P._ScriptSource then
      local lc = Instance.new("StringValue")
      lc.Name = "LogicCode"
      lc.Value = p14.P._ScriptSource
      lc.Parent = inst
    end
  end
  for _, ch in ipairs(p14.Ch or {}) do
    local c = f10(ch, v24)
    if c then c.Parent = inst end
  end
  if inst:IsA("Weld") or inst:IsA("WeldConstraint") or inst:IsA("Motor6D") or inst:IsA("ManualWeld") then
    f9(inst, p14.P._Part0Name, p14.P._Part1Name)
  end
  return inst
end

local v33 = "HuyPham_Saved_Index.json"

local function f11()
  if isfile and isfile(v33) then
    local ok, v = pcall(function() return httpService:JSONDecode(readfile(v33)) end)
    if ok and type(v) == "table" then return v end
  end
  return {}
end

local f12

local function f13(p16)
  local list = f11()
  for i, item in ipairs(list) do
    if item.FileName == p16 then
      if item.IsLocked then return false end
      if isfile and isfile(p16) and delfile then pcall(function() delfile(p16) end) end
      table.remove(list, i)
      break
    end
  end
  f12(list)
  return true
end

local function f14(name, category, data)
  local list = f11()
  local fname = "HuyPham_" .. tostring(tick()) .. ".json"
  if writefile then
    writefile(fname, httpService:JSONEncode(data))
    table.insert(list, { Name = name, Category = category, FileName = fname, IsLocked = false, Time = os.date("%X") })
    f12(list)
    return true
  end
  return false
end

local function f15(p18)
  local list = f11()
  for _, item in ipairs(list) do
    if item.FileName == p18 then item.IsLocked = not item.IsLocked; break end
  end
  f12(list)
end

local function f16(root, cls, out, visited)
  if not root then return end
  pcall(function()
    for _, d in ipairs(root:GetDescendants()) do
      if d:IsA(cls) and not visited[d] then
        visited[d] = true
        local s = f7(d)
        if s then table.insert(out, s) end
      end
    end
  end)
end

function f12(list)
  if writefile then pcall(function() writefile(v33, httpService:JSONEncode(list)) end) end
end

local function f17(p24)
  if isfile and isfile(p24) then
    local ok, v = pcall(function() return httpService:JSONDecode(readfile(p24)) end)
    if ok then return v end
  end
  return nil
end

local function f18(root, classes, out, visited)
  if not root then return end
  pcall(function()
    for _, d in ipairs(root:GetDescendants()) do
      for _, cls in ipairs(classes) do
        if d:IsA(cls) and not visited[d] then
          visited[d] = true
          local s = f7(d)
          if s then table.insert(out, s) end
          break
        end
      end
    end
  end)
end

local function f19()
  local keep = {}
  for _, item in ipairs(f11()) do
    if item.IsLocked then
      table.insert(keep, item)
    elseif isfile and isfile(item.FileName) and delfile then
      pcall(function() delfile(item.FileName) end)
    end
  end
  f12(keep)
end

-- ============================================================
-- HẾT PHẦN 1/4
-- ============================================================

-- ============================================================
-- HUY PHAM HUB — PHẦN 2/4
-- Tất cả hàm scan
-- ============================================================

-- ============================================================
-- COPY ALL
-- ============================================================
local function copyAllData()
  local result = {}
  local tools, visitedTools = {}, {}
  f16(workspace, "Tool", tools, visitedTools)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then f16(plr.Character, "Tool", tools, visitedTools) end
    if plr:FindFirstChild("Backpack") then f16(plr.Backpack, "Tool", tools, visitedTools) end
  end
  f16(starterPack, "Tool", tools, visitedTools)
  result.Tools = tools

  local guis = {}
  for _, v in ipairs((localPlayer:FindFirstChild("PlayerGui") or starterGui):GetChildren()) do
    if v.Name ~= "HuyPham_UI" then
      local s = f7(v)
      if s then table.insert(guis, s) end
    end
  end
  result.Gui = guis

  local nametags, visitedName = {}, {}
  f18(workspace, { "BillboardGui", "SurfaceGui" }, nametags, visitedName)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then
      f18(plr.Character, { "BillboardGui", "SurfaceGui" }, nametags, visitedName)
    end
  end
  result.Nametag = nametags

  local rs = {}
  for _, v in ipairs(replicatedStorage:GetChildren()) do
    local s = f7(v)
    if s then table.insert(rs, s) end
  end
  result.ReplicatedStorage = rs

  local light = {}
  local ls = f7(lighting)
  if ls then table.insert(light, ls) end
  result.Lighting = light

  local map = {}
  for _, v in ipairs(workspace:GetChildren()) do
    if not v:IsA("Terrain") and not v:IsA("Camera")
      and not players:GetPlayerFromCharacter(v) then
      local s = f7(v)
      if s then table.insert(map, s) end
    end
  end
  result.Map = map

  return result
end

-- ============================================================
-- VFX
-- ============================================================
local VFX_CLASSES = {
  "ParticleEmitter", "Beam", "Trail", "Fire", "Smoke", "Sparkles",
  "Explosion", "Light", "PointLight", "SpotLight", "SurfaceLight",
  "PostEffect", "Atmosphere", "Sky", "Clouds",
  "Sound", "Animation", "AnimationController", "Animator",
  "Highlight", "SelectionBox", "SelectionSphere", "BillboardGui",
  "SurfaceGui", "Decal", "Texture", "SpecialMesh", "BlockMesh", "CylinderMesh",
}

local function isVFXInstance(inst)
  for _, cls in ipairs(VFX_CLASSES) do
    if inst:IsA(cls) then return true end
  end
  return false
end

local function copyVFX()
  local vfxList = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and isVFXInstance(d) then
          visited[d] = true
          local s = f7(d)
          if s then table.insert(vfxList, s) end
        end
      end
    end)
  end
  scan(workspace)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  scan(replicatedStorage)
  scan(lighting)
  scan(starterGui)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  return vfxList
end

local function findParentModel(vfxInst)
  local parent = vfxInst.Parent
  while parent do
    if parent:IsA("Model") or parent:IsA("Tool") or parent:IsA("Accessory") then
      return parent
    end
    parent = parent.Parent
  end
  return nil
end

local function copyVFXWithModels()
  local result = {}
  local visited = {}
  local modelsAdded = {}
  local function scanContainer(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and isVFXInstance(d) then
          visited[d] = true
          local parentModel = findParentModel(d)
          if parentModel and not modelsAdded[parentModel] then
            modelsAdded[parentModel] = true
            local s = f7(parentModel)
            if s then table.insert(result, s) end
          elseif not parentModel then
            local s = f7(d)
            if s then table.insert(result, s) end
          end
        end
      end
    end)
  end
  scanContainer(workspace)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scanContainer(plr.Character) end
  end
  scanContainer(replicatedStorage)
  scanContainer(lighting)
  scanContainer(starterGui)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scanContainer(pg) end
  return result
end

local function copyVFXModelsOnly()
  local result = {}
  local visited = {}
  local modelsAdded = {}
  local function scanContainer(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and isVFXInstance(d) then
          visited[d] = true
          local parentModel = findParentModel(d)
          if parentModel and not modelsAdded[parentModel] then
            modelsAdded[parentModel] = true
            local s = f7(parentModel)
            if s then table.insert(result, s) end
          end
        end
      end
    end)
  end
  scanContainer(workspace)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scanContainer(plr.Character) end
  end
  scanContainer(replicatedStorage)
  scanContainer(starterGui)
  return result
end

-- ============================================================
-- ANIMATION
-- ============================================================
local function copyAnimations()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and (d:IsA("Animation") or d:IsA("Animator")) then
          visited[d] = true
          local s = f7(d)
          if s then table.insert(result, s) end
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  scan(starterPack)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  return result
end

-- ============================================================
-- REMOTE
-- ============================================================
local REMOTE_CLASSES = {
  "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent",
  "BindableEvent", "BindableFunction",
}

local function copyRemotes()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] then
          for _, cls in ipairs(REMOTE_CLASSES) do
            if d:IsA(cls) then
              visited[d] = true
              local s = f7(d)
              if s then table.insert(result, s) end
              break
            end
          end
        end
      end
    end)
  end
  scan(replicatedStorage)
  scan(workspace)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  scan(starterGui)
  return result
end

-- ============================================================
-- SOUND ID
-- ============================================================
local function copySoundIDs()
  local result = {}
  local visited = {}
  local seenIds = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and d:IsA("Sound") then
          visited[d] = true
          local sid = d.SoundId
          if sid and sid ~= "" and not seenIds[sid] then
            seenIds[sid] = true
            table.insert(result, {
              Cls = "Sound", Name = d.Name,
              P = { SoundId = sid, Volume = d.Volume, PlaybackSpeed = d.PlaybackSpeed, Looped = d.Looped },
              Ch = {},
            })
          end
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  scan(starterPack)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  return result
end

-- ============================================================
-- MESH / TEXTURE ID
-- ============================================================
local function copyMeshTextureIDs()
  local result = {}
  local visited = {}
  local seenIds = {}
  local function addMesh(inst, meshId)
    if not meshId or meshId == "" or seenIds[meshId] then return end
    seenIds[meshId] = true
    table.insert(result, { Cls = "MeshId", Name = inst.Name, P = { MeshId = meshId }, Ch = {} })
  end
  local function addTexture(inst, texId)
    if not texId or texId == "" or seenIds[texId] then return end
    seenIds[texId] = true
    table.insert(result, { Cls = "TextureId", Name = inst.Name, P = { TextureId = texId }, Ch = {} })
  end
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] then
          visited[d] = true
          if d:IsA("MeshPart") then
            pcall(function() addMesh(d, d.MeshId) end)
            pcall(function() addTexture(d, d.TextureID) end)
          elseif d:IsA("SpecialMesh") then
            pcall(function() addMesh(d, d.MeshId) end)
            pcall(function() addTexture(d, d.TextureId) end)
          elseif d:IsA("Decal") or d:IsA("Texture") then
            pcall(function() addTexture(d, d.Texture) end)
          end
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  return result
end

-- ============================================================
-- PLAYER INFO
-- ============================================================
local function copyPlayerInfo()
  local result = {}
  for _, plr in ipairs(players:GetPlayers()) do
    local info = {
      Cls = "Player", Name = plr.Name,
      P = { UserId = plr.UserId, DisplayName = plr.DisplayName, AccountAge = plr.AccountAge, Team = plr.Team and plr.Team.Name or "None" },
      Ch = {},
    }
    if plr.Character then
      local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
      if humanoid then
        info.P.WalkSpeed = humanoid.WalkSpeed
        info.P.JumpPower = humanoid.JumpPower
        info.P.Health = humanoid.Health
        info.P.MaxHealth = humanoid.MaxHealth
      end
      local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
      if hrp then info.P.Position = f1(hrp.Position) end
    end
    table.insert(result, info)
  end
  return result
end

-- ============================================================
-- SCRIPT SOURCE
-- ============================================================
local function copyScriptSource()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and (d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Script")) then
          visited[d] = true
          local s = f7(d)
          if s then table.insert(result, s) end
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  scan(starterPack)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  return result
end

-- ============================================================
-- PART POSITIONS
-- ============================================================
local function copyPartPositions()
  local result = {}
  local visited = {}
  pcall(function()
    for _, d in ipairs(workspace:GetDescendants()) do
      if not visited[d] and d:IsA("BasePart") then
        visited[d] = true
        table.insert(result, {
          Cls = d.ClassName, Name = d.Name,
          P = { Position = f1(d.Position), Size = f1(d.Size), CFrame = f1(d.CFrame), Anchored = d.Anchored, CanCollide = d.CanCollide, Transparency = d.Transparency, Color = f1(d.Color), Material = f1(d.Material) },
          Ch = {},
        })
      end
    end
  end)
  return result
end

-- ============================================================
-- ATTRIBUTE / TAG
-- ============================================================
local function copyAttributesTags()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] then
          visited[d] = true
          local attrs = {}
          pcall(function()
            for k, v in pairs(d:GetAttributes()) do attrs[k] = tostring(v) end
          end)
          local tags = {}
          pcall(function()
            for _, tag in ipairs(collectionService:GetTags(d)) do table.insert(tags, tag) end
          end)
          if next(attrs) or #tags > 0 then
            table.insert(result, { Cls = "AttrTag", Name = d:GetFullName(), P = { _Attrs = attrs, _Tags = tags }, Ch = {} })
          end
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  scan(starterPack)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  return result
end

-- ============================================================
-- HUMANOID DESCRIPTION / TOOLTIP
-- ============================================================
local function copyHumanoidDescription()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] then
          visited[d] = true
          if d:IsA("Humanoid") and d.Description ~= "" then
            table.insert(result, { Cls = "Humanoid", Name = d.Parent and d.Parent.Name or d.Name, P = { Description = d.Description }, Ch = {} })
          elseif d:IsA("Tool") and d.ToolTip ~= "" then
            table.insert(result, { Cls = "Tool", Name = d.Name, P = { ToolTip = d.ToolTip }, Ch = {} })
          end
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  return result
end

-- ============================================================
-- SPY: GAME INFO
-- ============================================================
local function copyGameInfo()
  local result = {}
  local function add(name, val)
    table.insert(result, { Cls = "GameInfo", Name = name, P = { Value = tostring(val) }, Ch = {} })
  end
  pcall(function()
    add("PlaceId", game.PlaceId)
    add("GameId", game.GameId)
    add("JobId", game.JobId)
    add("PlayerCount", #players:GetPlayers())
    add("Gravity", workspace.Gravity)
    add("StreamingEnabled", workspace.StreamingEnabled)
    add("ClockTime", lighting.ClockTime)
    add("FogEnd", lighting.FogEnd)
    add("Brightness", lighting.Brightness)
    local info = marketplaceService:GetProductInfo(game.PlaceId)
    if info then
      add("GameName", info.Name or "?")
      add("Creator", (info.Creator and info.Creator.Name) or "?")
      add("CreatorId", (info.Creator and info.Creator.Id) or "?")
      add("Playing", info.Playing or 0)
      add("MaxPlayers", info.MaxPlayers or 0)
      add("Created", info.Created or "?")
      add("Updated", info.Updated or "?")
    end
  end)
  return result
end

-- ============================================================
-- SPY: PLAYER AVATAR
-- ============================================================
local function copyPlayerAvatar()
  local result = {}
  for _, plr in ipairs(players:GetPlayers()) do
    pcall(function()
      local desc = plr:FindFirstChildOfClass("HumanoidDescription")
      if desc then
        local s = f7(desc)
        if s then s.P._Owner = plr.Name; table.insert(result, s) end
      end
      if plr.Character then
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then
          local d2 = h:FindFirstChildOfClass("HumanoidDescription")
          if d2 then
            local s2 = f7(d2)
            if s2 then s2.P._Owner = plr.Name; table.insert(result, s2) end
          end
        end
      end
    end)
  end
  return result
end

-- ============================================================
-- SPY: BACKPACK
-- ============================================================
local function copyBackpack()
  local result = {}
  for _, plr in ipairs(players:GetPlayers()) do
    local bp = plr:FindFirstChild("Backpack")
    if bp then
      pcall(function()
        for _, tool in ipairs(bp:GetChildren()) do
          if tool:IsA("Tool") then
            local s = f7(tool)
            if s then s.P._Owner = plr.Name; table.insert(result, s) end
          end
        end
      end)
    end
  end
  return result
end

-- ============================================================
-- SPY: TEAM + LEADERBOARD
-- ============================================================
local function copyTeamLeaderboard()
  local result = {}
  pcall(function()
    local teams = game:GetService("Teams"):GetTeams()
    for _, team in ipairs(teams) do
      table.insert(result, {
        Cls = "Team", Name = team.Name,
        P = { Color = f1(team.TeamColor.Color), MemberCount = tostring(#team:GetPlayers()) },
        Ch = {},
      })
    end
  end)
  for _, plr in ipairs(players:GetPlayers()) do
    local ls = plr:FindFirstChild("leaderstats")
    if ls then
      local stats = {}
      pcall(function()
        for _, stat in ipairs(ls:GetChildren()) do
          pcall(function() stats[stat.Name] = tostring(stat.Value) end)
        end
      end)
      table.insert(result, { Cls = "Leaderstats", Name = plr.Name, P = { _Stats = stats }, Ch = {} })
    end
  end
  return result
end

-- ============================================================
-- SPY: SOUND ĐANG PHÁT
-- ============================================================
local function copySoundPlaying()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and d:IsA("Sound") and d.Playing then
          visited[d] = true
          table.insert(result, {
            Cls = "Sound", Name = d.Name,
            P = { SoundId = d.SoundId, Volume = d.Volume, PlaybackSpeed = d.PlaybackSpeed, Looped = d.Looped },
            Ch = {},
          })
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  return result
end

-- ============================================================
-- SPY: BADGE / GAMEPASS
-- ============================================================
local function copyBadgesGamepasses()
  local result = {}
  pcall(function()
    local badges = game:GetService("BadgeService"):GetBadgesAsync(game.PlaceId)
    if badges then
      for _, b in ipairs(badges) do
        table.insert(result, { Cls = "Badge", Name = b.Name, P = { Id = tostring(b.Id), Description = tostring(b.Description) }, Ch = {} })
      end
    end
  end)
  pcall(function()
    local passes = marketplaceService:GetGamepassesAsync(game.PlaceId)
    if passes then
      for _, p in ipairs(passes) do
        table.insert(result, { Cls = "Gamepass", Name = p.Name, P = { Id = tostring(p.Id), Price = tostring(p.Price) }, Ch = {} })
      end
    end
  end)
  return result
end

-- ============================================================
-- DISCOVER: HIDDEN PARTS
-- ============================================================
local function copyHiddenParts()
  local result = {}
  pcall(function()
    for _, d in ipairs(workspace:GetDescendants()) do
      if d:IsA("BasePart") then
        local isHidden = false
        if d.Transparency >= 0.99 then isHidden = true end
        local nlow = d.Name:lower()
        if nlow:find("secret") or nlow:find("vault") or nlow:find("hidden") then isHidden = true end
        if isHidden then
          table.insert(result, {
            Cls = d.ClassName, Name = d.Name,
            P = {
              Position = f1(d.Position), Size = f1(d.Size),
              Transparency = d.Transparency, CanCollide = d.CanCollide,
              Anchored = d.Anchored, FullName = d:GetFullName(),
            },
            Ch = {},
          })
        end
      end
    end
  end)
  return result
end

-- ============================================================
-- DISCOVER: PROXIMITY PROMPT
-- ============================================================
local function copyProximityPrompts()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and d:IsA("ProximityPrompt") then
          visited[d] = true
          table.insert(result, {
            Cls = "ProximityPrompt", Name = d.Name,
            P = {
              ActionText = d.ActionText, ObjectText = d.ObjectText,
              HoldDuration = d.HoldDuration, MaxActivationDistance = d.MaxActivationDistance,
              Enabled = d.Enabled,
              ParentName = d.Parent and d.Parent:GetFullName() or "?",
            },
            Ch = {},
          })
        end
      end
    end)
  end
  scan(workspace)
  scan(replicatedStorage)
  scan(starterGui)
  scan(starterPack)
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then scan(plr.Character) end
  end
  return result
end

-- ============================================================
-- DISCOVER: GUI TEXT
-- ============================================================
local function copyGuiText()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] then
          visited[d] = true
          if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            if d.Text and d.Text ~= "" then
              table.insert(result, {
                Cls = d.ClassName, Name = d.Name,
                P = { Text = d.Text, Visible = d.Visible, FullName = d:GetFullName() },
                Ch = {},
              })
            end
          end
        end
      end
    end)
  end
  scan(starterGui)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  return result
end

-- ============================================================
-- DISCOVER: GAME CONFIG
-- ============================================================
local function copyGameConfig()
  local result = {}
  local visited = {}
  local keywords = { "config", "setting", "stat", "rate", "damage", "speed", "value", "data", "balance", "price" }
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] then
          visited[d] = true
          local nlow = d.Name:lower()
          local isConfig = false
          for _, kw in ipairs(keywords) do
            if nlow:find(kw) then isConfig = true; break end
          end
          if isConfig and (d:IsA("NumberValue") or d:IsA("StringValue") or d:IsA("BoolValue")
            or d:IsA("IntValue") or d:IsA("ModuleScript") or d:IsA("Configuration")) then
            local s = f7(d)
            if s then table.insert(result, s) end
          end
        end
      end
    end)
  end
  scan(replicatedStorage)
  scan(workspace)
  scan(starterGui)
  scan(starterPack)
  return result
end

-- ============================================================
-- DISCOVER: ANTI-CHEAT
-- ============================================================
local function copyAntiCheat()
  local result = {}
  local visited = {}
  local patterns = { "anticheat", "anti_cheat", "anti cheat", "ac_", "_ac", "detect", "kick", "ban", "exploit", "cheat" }
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and (d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Script")) then
          visited[d] = true
          local nlow = d.Name:lower()
          for _, p in ipairs(patterns) do
            if nlow:find(p) then
              local s = f7(d)
              if s then table.insert(result, s) end
              break
            end
          end
        end
      end
    end)
  end
  scan(replicatedStorage)
  scan(workspace)
  scan(starterGui)
  scan(starterPack)
  local pg = localPlayer:FindFirstChild("PlayerGui")
  if pg then scan(pg) end
  return result
end

-- ============================================================
-- DISCOVER: DATASTORE KEY
-- ============================================================
local function copyDataStoreKeys()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and (d:IsA("LocalScript") or d:IsA("ModuleScript")) then
          visited[d] = true
          pcall(function()
            if not decompile then return end
            local src = decompile(d)
            if not src then return end
            local keys = {}
            for k in src:gmatch('GetDataStore%s*%(%s*"([^"]+)"') do table.insert(keys, k) end
            for k in src:gmatch("GetDataStore%s*%(%s*'([^']+)'") do table.insert(keys, k) end
            if #keys > 0 then
              table.insert(result, {
                Cls = "DataStoreKey", Name = d.Name,
                P = { _Keys = keys, FullName = d:GetFullName() },
                Ch = {},
              })
            end
          end)
        end
      end
    end)
  end
  scan(replicatedStorage)
  scan(workspace)
  scan(starterGui)
  return result
end

-- ============================================================
-- DISCOVER: HTTP / WEBHOOK
-- ============================================================
local function copyHttpWebhooks()
  local result = {}
  local visited = {}
  local function scan(root)
    if not root then return end
    pcall(function()
      for _, d in ipairs(root:GetDescendants()) do
        if not visited[d] and (d:IsA("LocalScript") or d:IsA("ModuleScript")) then
          visited[d] = true
          pcall(function()
            if not decompile then return end
            local src = decompile(d)
            if not src then return end
            local urls = {}
            for u in src:gmatch('(https?://[^%s"\']+)') do table.insert(urls, u) end
            if #urls > 0 then
              table.insert(result, {
                Cls = "HTTPURL", Name = d.Name,
                P = { _URLs = urls, FullName = d:GetFullName() },
                Ch = {},
              })
            end
          end)
        end
      end
    end)
  end
  scan(replicatedStorage)
  scan(workspace)
  scan(starterGui)
  return result
end

-- ============================================================
-- CLONE: FULL CHARACTER
-- ============================================================
local function copyFullCharacter()
  local result = {}
  for _, plr in ipairs(players:GetPlayers()) do
    if plr.Character then
      local s = f7(plr.Character)
      if s then
        s.P._Owner = plr.Name
        table.insert(result, s)
      end
    end
  end
  return result
end

-- ============================================================
-- CLONE: NPC
-- ============================================================
local function copyNPCs()
  local result = {}
  local visited = {}
  pcall(function()
    for _, d in ipairs(workspace:GetDescendants()) do
      if not visited[d] and d:IsA("Model") and d ~= localPlayer.Character then
        local h = d:FindFirstChildOfClass("Humanoid")
        if h and not players:GetPlayerFromCharacter(d) then
          visited[d] = true
          local s = f7(d)
          if s then table.insert(result, s) end
        end
      end
    end
  end)
  return result
end

-- ============================================================
-- CLONE: VEHICLE / SEAT
-- ============================================================
local function copyVehicles()
  local result = {}
  local classes = { "VehicleSeat", "Seat", "VehicleWheel", "HingeConstraint", "PrismaticConstraint" }
  local visited = {}
  pcall(function()
    for _, d in ipairs(workspace:GetDescendants()) do
      if not visited[d] then
        for _, cls in ipairs(classes) do
          if d:IsA(cls) then
            visited[d] = true
            local s = f7(d)
            if s then table.insert(result, s) end
            break
          end
        end
      end
    end
  end)
  return result
end

-- ============================================================
-- CLONE: MODEL BOUNDING BOX
-- ============================================================
local function copyModelBoundingBox()
  local result = {}
  pcall(function()
    for _, d in ipairs(workspace:GetDescendants()) do
      if d:IsA("Model") and not players:GetPlayerFromCharacter(d) then
        pcall(function()
          local cf, size = d:GetBoundingBox()
          table.insert(result, {
            Cls = "Model", Name = d.Name,
            P = { CFrame = f1(cf), Size = f1(size), FullName = d:GetFullName() },
            Ch = {},
          })
        end)
      end
    end
  end)
  return result
end

-- ============================================================
-- CLONE: LIGHTING PRESET
-- ============================================================
local function copyLightingPreset()
  local result = {}
  local effectClasses = { "BloomEffect", "BlurEffect", "ColorCorrectionEffect", "SunRaysEffect",
    "DepthOfFieldEffect", "Atmosphere", "Sky", "ColorGradingEffect" }
  local visited = {}
  pcall(function()
    for _, d in ipairs(lighting:GetDescendants()) do
      if not visited[d] then
        for _, cls in ipairs(effectClasses) do
          if d:IsA(cls) then
            visited[d] = true
            local s = f7(d)
            if s then table.insert(result, s) end
            break
          end
        end
      end
    end
    local ls = f7(lighting)
    if ls then table.insert(result, ls) end
  end)
  return result
end

-- ============================================================
-- ANALYZE
-- ============================================================
local function analyzeSavedData(data)
  local stats = { Parts = 0, Tools = 0, Gui = 0, Scripts = 0, Sounds = 0, Lights = 0, Other = 0, Total = 0, HasScript = false, VFX = 0, Anim = 0, Remote = 0 }

  local function isVFXClass(cls)
    for _, vc in ipairs(VFX_CLASSES) do if cls == vc then return true end end
    return false
  end

  local function isRemoteClass(cls)
    for _, rc in ipairs(REMOTE_CLASSES) do if cls == rc then return true end end
    return false
  end

  local function walk(items)
    if not items then return end
    for _, item in ipairs(items) do
      stats.Total = stats.Total + 1
      local cls = item.Cls or ""
      if cls:match("Part$") or cls == "MeshPart" or cls == "UnionOperation" then
        stats.Parts = stats.Parts + 1
      elseif cls == "Tool" then
        stats.Tools = stats.Tools + 1
      elseif cls:match("Gui") or cls:match("Button") or cls:match("Label") or cls:match("Frame") or cls:match("Box") then
        stats.Gui = stats.Gui + 1
      elseif cls == "LocalScript" or cls == "ModuleScript" or cls == "Script" then
        stats.Scripts = stats.Scripts + 1
        stats.HasScript = true
      elseif cls == "Sound" then
        stats.Sounds = stats.Sounds + 1
      elseif cls == "Animation" or cls == "Animator" then
        stats.Anim = stats.Anim + 1
      elseif isRemoteClass(cls) then
        stats.Remote = stats.Remote + 1
      elseif cls:match("Light") then
        stats.Lights = stats.Lights + 1
      elseif isVFXClass(cls) then
        stats.VFX = stats.VFX + 1
      else
        stats.Other = stats.Other + 1
      end
      if item.Ch then walk(item.Ch) end
    end
  end
  walk(data)
  return stats
end


-- ============================================================
-- HUY PHAM HUB — PHẦN 2.5: LEAK MỞ RỘNG
-- Script / Map / Gui / Avatar / Info (đọc dữ liệu client đã tải về)
-- ============================================================
local Leaks = {}
do
  local starterPlayer = game:GetService("StarterPlayer")
  local replicatedFirst = game:GetService("ReplicatedFirst")
  local materialService = game:GetService("MaterialService")
  local textChatService = game:GetService("TextChatService")
  local statsService = game:GetService("Stats")
  local soundService = game:GetService("SoundService")
  local teamsService = game:GetService("Teams")

  local function info(cls, name, props)
    return { Cls = cls, Name = tostring(name), P = props or {}, Ch = {} }
  end

  local function safe(fn, fallback)
    local ok, res = pcall(fn)
    if ok then return res end
    return fallback
  end

  local function fullName(inst)
    return safe(function() return inst:GetFullName() end, tostring(inst))
  end

  local function clean(v)
    if type(v) == "number" and (v ~= v or v == math.huge or v == -math.huge) then
      return tostring(v)
    end
    return v
  end

  local function put(props, key, getter)
    local ok, v = pcall(getter)
    if ok and v ~= nil then
      local s = f1(v)
      if s == nil then s = tostring(v) end
      props[key] = clean(s)
    end
  end

  local function walk(rootList, test, build, limit)
    local result, visited = {}, {}
    for _, root in ipairs(rootList) do
      pcall(function()
        for _, d in ipairs(root:GetDescendants()) do
          if not visited[d] then
            local ok, hit = pcall(test, d)
            if ok and hit then
              visited[d] = true
              local okb, item = pcall(build, d)
              if okb and item then table.insert(result, item) end
              if limit and #result >= limit then return end
            end
          end
        end
      end)
      if limit and #result >= limit then break end
    end
    return result
  end

  local function worldRoots()
    local list = { workspace, replicatedStorage, replicatedFirst, starterPack, starterGui, starterPlayer }
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then table.insert(list, pg) end
    local ps = localPlayer:FindFirstChild("PlayerScripts")
    if ps then table.insert(list, ps) end
    local bp = localPlayer:FindFirstChild("Backpack")
    if bp then table.insert(list, bp) end
    return list
  end

  local function guiRoots()
    local list = { starterGui }
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then table.insert(list, pg) end
    return list
  end

  local function eachCharacter(fn)
    for _, plr in ipairs(players:GetPlayers()) do
      if plr.Character then pcall(fn, plr, plr.Character) end
    end
  end

  -- ---------------------------------------------------------- SCRIPT
  local function topScript(d, cls)
    return d:IsA(cls) and not d:FindFirstAncestorWhichIsA("LuaSourceContainer")
  end

  function Leaks.localScripts()
    return walk(worldRoots(), function(d) return topScript(d, "LocalScript") end, f7)
  end

  function Leaks.moduleScripts()
    return walk(worldRoots(), function(d) return topScript(d, "ModuleScript") end, f7)
  end

  function Leaks.starterScripts()
    local list = { starterPlayer }
    local ps = localPlayer:FindFirstChild("PlayerScripts")
    if ps then table.insert(list, ps) end
    if localPlayer.Character then table.insert(list, localPlayer.Character) end
    return walk(list, function(d) return topScript(d, "LuaSourceContainer") end, f7)
  end

  function Leaks.replicatedFirst()
    local result = {}
    for _, child in ipairs(replicatedFirst:GetChildren()) do
      local s = f7(child)
      if s then table.insert(result, s) end
    end
    return result
  end

  function Leaks.toolScripts()
    return walk(worldRoots(), function(d)
      return d:IsA("Tool") and d:FindFirstChildWhichIsA("LuaSourceContainer", true) ~= nil
    end, f7)
  end

  function Leaks.scriptList()
    return walk(worldRoots(), function(d) return d:IsA("LuaSourceContainer") end, function(d)
      local props = { Class = d.ClassName, Path = fullName(d) }
      put(props, "Disabled", function() return d.Disabled end)
      put(props, "RunContext", function() return d.RunContext end)
      return info("ScriptInfo", d.Name, props)
    end, 4000)
  end

  -- ---------------------------------------------------------- MAP
  function Leaks.terrain()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return {} end
    local props = {}
    for _, name in ipairs({ "WaterColor", "WaterReflectance", "WaterTransparency", "WaterWaveSize", "WaterWaveSpeed", "Decoration", "GrassLength", "MaxExtents" }) do
      put(props, name, function() return terrain[name] end)
    end
    for _, material in ipairs({ "Grass", "Sand", "Rock", "Mud", "Slate", "Ground", "Basalt", "Snow", "Ice", "Salt", "Sandstone", "Limestone", "Pavement", "CrackedLava", "Asphalt", "Cobblestone", "LeafyGrass", "Glacier", "WoodPlanks" }) do
      put(props, "Color_" .. material, function() return terrain:GetMaterialColor(Enum.Material[material]) end)
    end
    return { info("Terrain", "Terrain", props) }
  end

  function Leaks.spawns()
    return walk({ workspace }, function(d) return d:IsA("SpawnLocation") end, f7)
  end

  function Leaks.touchParts()
    return walk({ workspace }, function(d)
      return d:IsA("BasePart") and d:FindFirstChildOfClass("TouchTransmitter") ~= nil
    end, function(d)
      local props = { Path = fullName(d) }
      put(props, "Position", function() return d.Position end)
      put(props, "Size", function() return d.Size end)
      put(props, "Color", function() return d.Color end)
      put(props, "CanCollide", function() return d.CanCollide end)
      put(props, "Transparency", function() return d.Transparency end)
      put(props, "Anchored", function() return d.Anchored end)
      return info("TouchPart", d.Name, props)
    end, 3000)
  end

  function Leaks.clickDetectors()
    return walk({ workspace }, function(d) return d:IsA("ClickDetector") end, function(d)
      local part = d.Parent
      local props = { Path = fullName(d) }
      put(props, "MaxActivationDistance", function() return d.MaxActivationDistance end)
      if part and part:IsA("BasePart") then put(props, "Position", function() return part.Position end) end
      return info("ClickDetector", part and part.Name or d.Name, props)
    end, 3000)
  end

  function Leaks.modelList()
    local result = {}
    for _, child in ipairs(workspace:GetChildren()) do
      if (child:IsA("Model") or child:IsA("Folder")) and not players:GetPlayerFromCharacter(child) then
        local props = { Class = child.ClassName }
        put(props, "Children", function() return #child:GetChildren() end)
        put(props, "Descendants", function() return #child:GetDescendants() end)
        if child:IsA("Model") then
          put(props, "Size", function() return child:GetExtentsSize() end)
          put(props, "Position", function() return child:GetPivot().Position end)
        end
        table.insert(result, info("ModelInfo", child.Name, props))
      end
    end
    return result
  end

  function Leaks.surfaceAppearances()
    local seen = {}
    return walk(worldRoots(), function(d) return d:IsA("SurfaceAppearance") end, function(d)
      local key = tostring(d.ColorMap) .. "|" .. tostring(d.NormalMap)
      if seen[key] then return nil end
      seen[key] = true
      local props = { Path = fullName(d) }
      for _, name in ipairs({ "ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap", "AlphaMode" }) do
        put(props, name, function() return d[name] end)
      end
      return info("SurfaceAppearance", d.Name, props)
    end, 3000)
  end

  function Leaks.materialVariants()
    return walk({ materialService }, function(d) return d:IsA("MaterialVariant") end, function(d)
      local props = {}
      for _, name in ipairs({ "BaseMaterial", "ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap", "StudsPerTile", "MaterialPattern" }) do
        put(props, name, function() return d[name] end)
      end
      return info("MaterialVariant", d.Name, props)
    end)
  end

  -- ---------------------------------------------------------- GUI
  function Leaks.guiButtons()
    return walk(guiRoots(), function(d) return d:IsA("TextButton") or d:IsA("ImageButton") end, function(d)
      local props = { Class = d.ClassName, Path = fullName(d) }
      put(props, "Visible", function() return d.Visible end)
      put(props, "Text", function() return d.Text end)
      put(props, "Image", function() return d.Image end)
      return info("GuiButton", d.Name, props)
    end, 4000)
  end

  function Leaks.imageIds()
    local seen = {}
    return walk(guiRoots(), function(d) return d:IsA("ImageLabel") or d:IsA("ImageButton") end, function(d)
      local id = d.Image
      if id == "" or seen[id] then return nil end
      seen[id] = true
      local props = { Image = id, Path = fullName(d) }
      put(props, "ImageRectOffset", function() return d.ImageRectOffset end)
      put(props, "ImageRectSize", function() return d.ImageRectSize end)
      return info("ImageId", d.Name, props)
    end, 4000)
  end

  function Leaks.hiddenScreenGuis()
    return walk(guiRoots(), function(d) return d:IsA("ScreenGui") and d.Enabled == false end, f7)
  end

  function Leaks.hiddenFrames()
    return walk(guiRoots(), function(d)
      if not d:IsA("GuiObject") or d.Visible then return false end
      local parent = d.Parent
      return parent ~= nil and (not parent:IsA("GuiObject") or parent.Visible)
    end, f7, 800)
  end

  function Leaks.fontsUsed()
    local counts = {}
    walk(guiRoots(), function(d)
      return d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")
    end, function(d)
      local key = tostring(d.Font)
      counts[key] = (counts[key] or 0) + 1
      return nil
    end)
    local result = {}
    for font, n in pairs(counts) do
      table.insert(result, info("FontInfo", font, { Count = n }))
    end
    table.sort(result, function(a, b) return a.P.Count > b.P.Count end)
    return result
  end

  function Leaks.colorPalette()
    local counts = {}
    walk(guiRoots(), function(d)
      return d:IsA("GuiObject") and d.BackgroundTransparency < 1
    end, function(d)
      local c = d.BackgroundColor3
      local key = string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
      counts[key] = (counts[key] or 0) + 1
      return nil
    end)
    local result = {}
    for hex, n in pairs(counts) do
      table.insert(result, info("ColorInfo", hex, { Count = n }))
    end
    table.sort(result, function(a, b) return a.P.Count > b.P.Count end)
    while #result > 40 do table.remove(result) end
    return result
  end

  -- ---------------------------------------------------------- AVATAR
  function Leaks.accessories()
    local result = {}
    eachCharacter(function(plr, char)
      for _, d in ipairs(char:GetChildren()) do
        if d:IsA("Accessory") then
          local s = f7(d)
          if s then
            s.P._Owner = plr.Name
            table.insert(result, s)
          end
        end
      end
    end)
    return result
  end

  function Leaks.clothing()
    local result = {}
    eachCharacter(function(plr, char)
      for _, d in ipairs(char:GetChildren()) do
        local props = { Class = d.ClassName, Owner = plr.Name }
        if d:IsA("Shirt") then
          put(props, "Template", function() return d.ShirtTemplate end)
          table.insert(result, info("Clothing", plr.Name .. " Shirt", props))
        elseif d:IsA("Pants") then
          put(props, "Template", function() return d.PantsTemplate end)
          table.insert(result, info("Clothing", plr.Name .. " Pants", props))
        elseif d:IsA("ShirtGraphic") then
          put(props, "Template", function() return d.Graphic end)
          table.insert(result, info("Clothing", plr.Name .. " Graphic", props))
        end
      end
    end)
    return result
  end

  function Leaks.bodyColors()
    local result = {}
    eachCharacter(function(plr, char)
      local bc = char:FindFirstChildOfClass("BodyColors")
      if not bc then return end
      local props = { Owner = plr.Name }
      for _, name in ipairs({ "HeadColor3", "TorsoColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3" }) do
        put(props, name, function() return bc[name] end)
      end
      table.insert(result, info("BodyColors", plr.Name, props))
    end)
    return result
  end

  function Leaks.playingAnims()
    local result, seen = {}, {}
    eachCharacter(function(plr, char)
      local humanoid = char:FindFirstChildOfClass("Humanoid")
      local animator = (humanoid and humanoid:FindFirstChildOfClass("Animator")) or char:FindFirstChildWhichIsA("Animator", true)
      if not animator then return end
      for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local id = track.Animation and track.Animation.AnimationId or ""
        if id ~= "" and not seen[id] then
          seen[id] = true
          local props = { AnimationId = id, Owner = plr.Name }
          put(props, "Length", function() return track.Length end)
          put(props, "Looped", function() return track.Looped end)
          put(props, "Priority", function() return track.Priority end)
          put(props, "Speed", function() return track.Speed end)
          table.insert(result, info("AnimTrack", track.Name, props))
        end
      end
    end)
    return result
  end

  function Leaks.rigJoints()
    local result = {}
    eachCharacter(function(plr, char)
      for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Motor6D") then
          local props = { Owner = plr.Name, Part0 = d.Part0 and d.Part0.Name or "", Part1 = d.Part1 and d.Part1.Name or "" }
          put(props, "C0", function() return d.C0 end)
          put(props, "C1", function() return d.C1 end)
          table.insert(result, info("Motor6D", d.Name, props))
        end
      end
    end)
    return result
  end

  -- ---------------------------------------------------------- INFO / REMOTE
  function Leaks.valueObjects()
    return walk({ replicatedStorage, workspace, players }, function(d) return d:IsA("ValueBase") end, function(d)
      local props = { Class = d.ClassName, Path = fullName(d) }
      props.Value = tostring(safe(function() return d.Value end, nil))
      return info("ValueObject", d.Name, props)
    end, 4000)
  end

  local function dump(value, depth, seen)
    local kind = typeof(value)
    if kind == "string" then
      if #value > 400 then return value:sub(1, 400) .. "..." end
      return value
    elseif kind == "number" then
      return clean(value)
    elseif kind == "boolean" then
      return value
    elseif kind == "table" then
      if depth <= 0 or seen[value] then return "<table>" end
      seen[value] = true
      local out, count = {}, 0
      for k, v in pairs(value) do
        count = count + 1
        if count > 150 then
          out["..."] = "truncated"
          break
        end
        out[tostring(k)] = dump(v, depth - 1, seen)
      end
      seen[value] = nil
      return out
    elseif kind == "Instance" then
      return "<Instance " .. fullName(value) .. ">"
    end
    local s = f1(value)
    if s ~= nil then return s end
    return "<" .. kind .. ">"
  end

  function Leaks.moduleConfig()
    local mods = walk({ replicatedStorage, replicatedFirst }, function(d)
      return d:IsA("ModuleScript")
    end, function(d) return d end, 400)

    local result = {}
    for _, mod in ipairs(mods) do
      local done, ok, res = false, false, nil
      task.spawn(function()
        ok, res = pcall(require, mod)
        done = true
      end)
      local started = os.clock()
      while not done and os.clock() - started < 2 do task.wait() end
      if done and ok and type(res) == "table" then
        table.insert(result, info("ModuleData", mod.Name, { Path = fullName(mod), Data = dump(res, 4, {}) }))
      end
    end
    return result
  end

  function Leaks.chatCommands()
    local result = {}
    pcall(function()
      for _, d in ipairs(textChatService:GetDescendants()) do
        if d:IsA("TextChatCommand") then
          local props = { Path = fullName(d) }
          put(props, "PrimaryAlias", function() return d.PrimaryAlias end)
          put(props, "SecondaryAlias", function() return d.SecondaryAlias end)
          put(props, "Enabled", function() return d.Enabled end)
          table.insert(result, info("ChatCommand", d.Name, props))
        elseif d:IsA("TextChannel") then
          table.insert(result, info("ChatChannel", d.Name, { Path = fullName(d) }))
        end
      end
    end)
    return result
  end

  -- ---------------------------------------------------------- SPY
  function Leaks.gameSettings()
    local result = {}
    local function add(group, name, getter)
      local ok, v = pcall(getter)
      if ok and v ~= nil then
        table.insert(result, info("Setting", group .. "." .. name, { Value = tostring(v) }))
      end
    end
    for _, name in ipairs({ "Gravity", "FallenPartsDestroyHeight", "StreamingEnabled", "StreamingMinRadius", "StreamingTargetRadius", "AirDensity", "GlobalWind", "AllowThirdPartySales" }) do
      add("Workspace", name, function() return workspace[name] end)
    end
    for _, name in ipairs({ "CameraMode", "CameraMaxZoomDistance", "CameraMinZoomDistance", "CharacterWalkSpeed", "CharacterJumpPower", "CharacterJumpHeight", "CharacterUseJumpPower", "CharacterMaxSlopeAngle", "EnableMouseLockOption", "HealthDisplayDistance", "NameDisplayDistance", "LoadCharacterAppearance", "AutoJumpEnabled", "UserEmotesEnabled" }) do
      add("StarterPlayer", name, function() return starterPlayer[name] end)
    end
    for _, name in ipairs({ "CharacterAutoLoads", "RespawnTime", "MaxPlayers", "BubbleChat", "ClassicChat" }) do
      add("Players", name, function() return players[name] end)
    end
    for _, name in ipairs({ "Technology", "ClockTime", "TimeOfDay", "GlobalShadows", "Brightness", "EnvironmentDiffuseScale", "EnvironmentSpecularScale" }) do
      add("Lighting", name, function() return lighting[name] end)
    end
    add("SoundService", "RespectFilteringEnabled", function() return soundService.RespectFilteringEnabled end)
    add("SoundService", "AmbientReverb", function() return soundService.AmbientReverb end)
    add("Teams", "Count", function() return #teamsService:GetChildren() end)
    return result
  end

  function Leaks.cameraInfo()
    local result = {}
    local cam = workspace.CurrentCamera
    if not cam then return result end
    for _, name in ipairs({ "CameraType", "FieldOfView", "DiagonalFieldOfView", "MaxAxisFieldOfView", "CFrame", "Focus", "HeadLocked", "NearPlaneZ", "ViewportSize" }) do
      local ok, v = pcall(function() return cam[name] end)
      if ok and v ~= nil then
        table.insert(result, info("Camera", name, { Value = tostring(v) }))
      end
    end
    return result
  end

  function Leaks.serverStats()
    local result = {}
    local function add(name, value)
      table.insert(result, info("Stat", name, { Value = tostring(value) }))
    end
    pcall(function() add("Network ping (ms)", math.floor(localPlayer:GetNetworkPing() * 1000)) end)
    pcall(function() add("FPS", math.floor(1 / runService.RenderStepped:Wait())) end)
    pcall(function() add("Players", #players:GetPlayers()) end)
    pcall(function() add("MaxPlayers", players.MaxPlayers) end)
    pcall(function() add("Memory (MB)", math.floor(statsService:GetTotalMemoryUsageMb())) end)
    pcall(function() add("Instances", statsService.InstanceCount) end)
    pcall(function() add("Game time (s)", math.floor(workspace.DistributedGameTime)) end)
    pcall(function() add("PlaceVersion", game.PlaceVersion) end)
    return result
  end

  -- ---------------------------------------------------------- DISCOVER
  function Leaks.explorerTree()
    local result = {}
    local MAX, DEPTH = 3500, 3
    local function visit(inst, depth, path)
      for _, child in ipairs(inst:GetChildren()) do
        if #result >= MAX then return end
        local childPath = path .. "." .. child.Name
        table.insert(result, info("Node", child.Name, { Class = child.ClassName, Path = childPath, Depth = depth, Children = #child:GetChildren() }))
        if depth < DEPTH then visit(child, depth + 1, childPath) end
      end
    end
    local services = { workspace, replicatedStorage, replicatedFirst, starterGui, starterPack, starterPlayer, lighting, soundService, teamsService }
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then table.insert(services, pg) end
    for _, service in ipairs(services) do
      if #result >= MAX then break end
      pcall(function()
        table.insert(result, info("Service", service.Name, { Class = service.ClassName, Children = #service:GetChildren() }))
        visit(service, 1, service.Name)
      end)
    end
    return result
  end
end


-- ============================================================
-- MENU (khung Skyro UI) + toàn bộ tính năng của HUY PHAM HUB
-- ============================================================
local function buildHub()
local PURPLE = Color3.fromRGB(146, 112, 255)
local LILAC  = Color3.fromRGB(196, 178, 255)
local INK    = Color3.fromRGB(236, 232, 250)
local DIM    = Color3.fromRGB(152, 144, 184)
local WHITE  = Color3.fromRGB(255, 255, 255)

local SURFACE_2 = Color3.fromRGB(36, 33, 49)
local SURFACE_3 = Color3.fromRGB(47, 43, 63)
local STROKE    = Color3.fromRGB(66, 59, 92)
local VIOLET    = Color3.fromRGB(118, 80, 240)
local ORCHID    = Color3.fromRGB(178, 124, 255)
local MIST      = Color3.fromRGB(54, 48, 76)
local BASE      = Color3.fromRGB(26, 24, 35)   
local CARD      = Color3.fromRGB(40, 37, 54)   
local CARD_HI   = Color3.fromRGB(52, 47, 71)   

local GLASS    = 0.18   
local GLASS_HI = 0.04   

local ACCENT_GRADIENT = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, VIOLET),
    ColorSequenceKeypoint.new(0.55, PURPLE),
    ColorSequenceKeypoint.new(1.00, ORCHID),
})

local SHINE_GRADIENT = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, LILAC),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(176, 150, 255)),
    ColorSequenceKeypoint.new(0.50, WHITE),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(176, 150, 255)),
    ColorSequenceKeypoint.new(1.00, LILAC),
})

local COLORS = {
    up     = Color3.fromRGB(72, 199, 142),
    down   = Color3.fromRGB(255, 92, 110),
    middle = Color3.fromRGB(255, 168, 64),
}

local Fx = {
    enabled     = v6.Fx ~= false,
    clock       = 0,
    flow        = 0,     
    energy      = 0,     
    flash       = 0,     
    order       = 0,
    connections = {},
    animators   = {},
    shines      = {},
}

local function bind(signal, fn)
    local connection = signal:Connect(fn)
    table.insert(Fx.connections, connection)
    return connection
end

local function animate(fn)
    table.insert(Fx.animators, fn)
    return fn
end

local function nextOrder()
    Fx.order = Fx.order + 1
    return Fx.order
end

local function tween(object, time, props, style, direction)
    local playing = nil
    pcall(function()
        playing = tweenService:Create(object, TweenInfo.new(time or 0.22,
            style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
        playing:Play()
    end)
    return playing
end

local function corner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = (typeof(radius) == "UDim") and radius or UDim.new(0, radius or 12)
    item.Parent = parent
    return item
end

local function round(parent)
    return corner(parent, UDim.new(1, 0))
end

local function outline(parent, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color or STROKE
    item.Thickness = thickness or 1
    item.Transparency = transparency or 0
    item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    item.Parent = parent
    return item
end

local function gradient(parent, colors, rotation, transparency)
    local item = Instance.new("UIGradient")
    item.Color = colors or ACCENT_GRADIENT
    item.Rotation = rotation or 0
    if transparency then item.Transparency = transparency end
    item.Parent = parent
    return item
end

local function fade(points)
    local keys = {}
    for index, point in ipairs(points) do
        keys[index] = NumberSequenceKeypoint.new(point[1], point[2])
    end
    return NumberSequence.new(keys)
end

local function pad(parent, left, right, top, bottom)
    local item = Instance.new("UIPadding")
    item.PaddingLeft = UDim.new(0, left or 0)
    item.PaddingRight = UDim.new(0, right or 0)
    item.PaddingTop = UDim.new(0, top or 0)
    item.PaddingBottom = UDim.new(0, bottom or 0)
    item.Parent = parent
    return item
end

local function frame(parent, props)
    local item = Instance.new("Frame")
    item.BorderSizePixel = 0
    item.BackgroundColor3 = WHITE
    for key, value in pairs(props or {}) do item[key] = value end
    item.Parent = parent
    return item
end

local function label(parent, size, weight, color)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1
    if weight == "black" then
        item.Font = Enum.Font.GothamBlack
    elseif weight then
        item.Font = Enum.Font.GothamBold
    else
        item.Font = Enum.Font.GothamMedium
    end
    item.TextSize = size or 12
    item.TextColor3 = color or INK
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Text = ""
    item.Parent = parent
    return item
end

local function softOrb(parent, color, diameter, strength)
    local holder = frame(parent, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(diameter, diameter),
    })

    local layers = 9
    local alpha = 1 - (1 - math.clamp(strength, 0, 0.99)) ^ (1 / layers)

    for index = 1, layers do
        local scale = (index / layers) ^ 0.8
        local ring = frame(holder, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(scale, scale),
            BackgroundColor3 = color,
            BackgroundTransparency = 1 - alpha,
        })
        round(ring)
    end

    return holder
end

local function focusRing(box, stroke, host)
    box.Focused:Connect(function()
        tween(stroke, 0.2, { Color = PURPLE, Thickness = 1.5 })
        tween(box, 0.2, { BackgroundTransparency = 0 })
        if host then tween(host, 0.2, { BackgroundTransparency = GLASS_HI }) end
    end)
    box.FocusLost:Connect(function()
        tween(stroke, 0.25, { Color = STROKE, Thickness = 1 })
        tween(box, 0.25, { BackgroundTransparency = 0.15 })
        if host then tween(host, 0.25, { BackgroundTransparency = GLASS }) end
    end)
end


local guiParent = coreGui
pcall(function()
    if type(gethui) == "function" then guiParent = gethui() end
end)

for _, holder in ipairs({ guiParent, coreGui }) do
    local previous = holder:FindFirstChild("HuyPham_UI")
    if previous then pcall(function() previous:Destroy() end) end
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "HuyPham_UI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 100000
Gui.Parent = guiParent

local WIDTH = math.clamp(tonumber(v6.SkyroW) or 600, 520, 980)
local HEIGHT = math.clamp(tonumber(v6.SkyroH) or 520, 400, 760)


local Screen = frame(Gui, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })

local Glow = frame(Screen, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(WIDTH, HEIGHT),
    BackgroundTransparency = 1,
    ZIndex = 0,
})

local GlowLayers = {}
for index = 1, 7 do
    local spread = index * 6
    local layer = frame(Glow, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 4 + index * 1.5),
        Size = UDim2.new(1, spread * 2, 1, spread * 2),
        BackgroundColor3 = (index <= 2) and LILAC or PURPLE,
        BackgroundTransparency = 0.9,
    })
    corner(layer, 22 + spread)
    GlowLayers[index] = layer
end

local Window = frame(Screen, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(WIDTH, HEIGHT),
    BackgroundTransparency = 1,
    ZIndex = 1,
})

local WindowScale = Instance.new("UIScale")
WindowScale.Scale = 0.86
WindowScale.Parent = Window

local Backdrop = nil
do
    local ok = pcall(function() Backdrop = Instance.new("CanvasGroup") end)
    if not ok or not Backdrop then
        Backdrop = Instance.new("Frame")
        Backdrop.ClipsDescendants = true
    end
end
Backdrop.Name = "Fluid"
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = BASE
Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 0
Backdrop.Parent = Window
corner(Backdrop, 22)

do
    local base = frame(Backdrop, { Size = UDim2.fromScale(1, 1), ZIndex = 1 })
    local baseGradient = gradient(base, ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(42, 38, 58)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(30, 28, 41)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(22, 20, 31)),
    }), 120)
    Fx.baseGradient = baseGradient
    Fx.baseDefault = baseGradient.Color

    local ORBS = {
        { color = PURPLE, size = 360, strength = 0.24, cx = 0.12, cy = 0.18, ax = 0.16, ay = 0.14, fx = 0.21, fy = 0.17, phase = 0.0, depth = 0.10 },
        { color = ORCHID, size = 330, strength = 0.20, cx = 0.88, cy = 0.22, ax = 0.14, ay = 0.18, fx = 0.15, fy = 0.23, phase = 1.7, depth = -0.08 },
        { color = VIOLET, size = 280, strength = 0.26, cx = 0.72, cy = 0.95, ax = 0.20, ay = 0.10, fx = 0.19, fy = 0.13, phase = 3.1, depth = 0.06 },
        { color = Color3.fromRGB(96, 56, 210), size = 400, strength = 0.24, cx = 0.30, cy = 0.88, ax = 0.18, ay = 0.12, fx = 0.12, fy = 0.18, phase = 4.4, depth = -0.05 },
        { color = LILAC,  size = 340, strength = 0.07, cx = 0.50, cy = 0.42, ax = 0.24, ay = 0.18, fx = 0.17, fy = 0.11, phase = 2.2, depth = 0.03 },
        { color = ORCHID, size = 210, strength = 0.14, cx = 0.55, cy = 0.10, ax = 0.30, ay = 0.06, fx = 0.09, fy = 0.21, phase = 5.3, depth = 0.14 },
    }

    local orbs = {}
    for index, spec in ipairs(ORBS) do
        local blob = softOrb(Backdrop, spec.color, spec.size, spec.strength)
        blob.ZIndex = 2
        blob.Position = UDim2.fromScale(spec.cx, spec.cy)
        orbs[index] = { blob = blob, spec = spec }
    end

    local cursorLight = frame(Backdrop, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })
    do
        local halo = softOrb(cursorLight, PURPLE, 10, 0.2)
        halo.Position = UDim2.fromScale(0.5, 0.5)
        halo.Size = UDim2.fromScale(1, 1)
        local core = softOrb(cursorLight, LILAC, 10, 0.16)
        core.Position = UDim2.fromScale(0.5, 0.5)
        core.Size = UDim2.fromScale(0.45, 0.45)
        core.ZIndex = 2
    end

    local RIBBON = fade({
        { 0, 1 }, { 0.36, 1 }, { 0.46, 0.95 }, { 0.5, 0.91 }, { 0.54, 0.95 }, { 0.64, 1 }, { 1, 1 },
    })
    local BANDS = {
        { rotation = 24,  speed = 0.09, phase = 0.0, color = ColorSequence.new(ORCHID, LILAC) },
        { rotation = -32, speed = 0.07, phase = 2.4, color = ColorSequence.new(LILAC, LILAC) },
        { rotation = 64,  speed = 0.05, phase = 4.1, color = ColorSequence.new(LILAC, ORCHID) },
    }

    local bands = {}
    for index, spec in ipairs(BANDS) do
        local band = frame(Backdrop, { Size = UDim2.fromScale(1, 1), ZIndex = 4 })
        bands[index] = { gradient = gradient(band, spec.color, spec.rotation, RIBBON), spec = spec }
    end

    local rng = Random.new()
    local sparks = {}
    for index = 1, 22 do
        local size = rng:NextInteger(2, 4)
        local dot = frame(Backdrop, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = (index % 3 == 0) and LILAC or WHITE,
            ZIndex = 5,
        })
        round(dot)
        sparks[index] = {
            dot = dot,
            x = rng:NextNumber(),
            y = rng:NextNumber(),
            ox = 0,
            oy = 0,
            speed = rng:NextNumber(0.012, 0.035),
            drift = rng:NextNumber(0.3, 1.2),
            phase = rng:NextNumber(0, math.pi * 2),
        }
    end

    local flash = frame(Backdrop, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = ORCHID,
        BackgroundTransparency = 1,
        ZIndex = 6,
    })

    local sheen = frame(Backdrop, { Size = UDim2.fromScale(1, 0.45), ZIndex = 7 })
    gradient(sheen, ColorSequence.new(WHITE), 90, fade({ { 0, 0.93 }, { 0.6, 0.985 }, { 1, 1 } }))

    local floor = frame(Backdrop, {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(1, 0.3),
        BackgroundColor3 = PURPLE,
        ZIndex = 7,
    })
    gradient(floor, ColorSequence.new(WHITE), 90, fade({ { 0, 1 }, { 1, 0.86 } }))

    function Fx.pulse()
        Fx.energy = 1
        Fx.flash = 1
    end

    function Fx.shock(rx, ry)
        local ring = frame(Backdrop, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(rx, ry),
            Size = UDim2.fromOffset(8, 8),
            BackgroundColor3 = ORCHID,
            BackgroundTransparency = 0.85,
            ZIndex = 5,
        })
        round(ring)
        local stroke = outline(ring, LILAC, 1.5, 0.4)

        tween(ring, 0.9, { Size = UDim2.fromOffset(230, 230), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
        tween(stroke, 0.9, { Transparency = 1, Thickness = 0.5 }, Enum.EasingStyle.Quart)
        task.delay(0.95, function() pcall(function() ring:Destroy() end) end)
    end

    local pointer = Vector2.new(0.5, 0.5)
    local presence = 0
    local lastMouse = nil

    local function relative(position)
        local origin, size = Backdrop.AbsolutePosition, Backdrop.AbsoluteSize
        local rx = (position.X - origin.X) / math.max(size.X, 1)
        local ry = (position.Y - origin.Y) / math.max(size.Y, 1)
        return rx, ry, (rx >= 0 and rx <= 1 and ry >= 0 and ry <= 1)
    end

    bind(userInputService.InputBegan, function(input)
        if not (Fx.enabled and Window.Visible) then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            local rx, ry, inside = relative(userInputService:GetMouseLocation())
            if inside then
                Fx.shock(rx, ry)
                Fx.energy = math.min(1, Fx.energy + 0.3)
            end
        end
    end)

    animate(function(_, dt)
        if not Window.Visible or not Fx.enabled then return end

        local mouse = userInputService:GetMouseLocation()
        local rx, ry, inside = relative(mouse)

        if lastMouse and inside then
            local speed = (mouse - lastMouse).Magnitude / math.max(dt, 1 / 240)
            Fx.energy = math.min(1, Fx.energy + speed * 0.000012)
        end
        lastMouse = mouse

        if inside then pointer = pointer:Lerp(Vector2.new(rx, ry), math.min(1, dt * 6)) end
        presence = presence + ((inside and 1 or 0) - presence) * math.min(1, dt * 4)
        Fx.energy = Fx.energy * math.exp(-dt * 1.3)
        Fx.flash = Fx.flash * math.exp(-dt * 2.6)

        Fx.flow = Fx.flow + dt * (1 + Fx.energy * 3.5)
        local t = Fx.flow

        baseGradient.Rotation = 120 + math.sin(t * 0.13) * 30

        local lean = (pointer - Vector2.new(0.5, 0.5)) * presence
        for _, orb in ipairs(orbs) do
            local spec = orb.spec
            local x = spec.cx + math.sin(t * spec.fx + spec.phase) * spec.ax + lean.X * spec.depth
            local y = spec.cy + math.cos(t * spec.fy + spec.phase * 1.3) * spec.ay + lean.Y * spec.depth
            local breathe = spec.size * (1 + math.sin(t * 0.5 + spec.phase) * 0.12 + Fx.energy * 0.1)
            orb.blob.Position = UDim2.fromScale(x, y)
            orb.blob.Size = UDim2.fromOffset(breathe, breathe)
        end

        local lightSize = 280 * presence * (1 + Fx.energy * 0.3)
        cursorLight.Position = UDim2.fromScale(pointer.X, pointer.Y)
        cursorLight.Size = UDim2.fromOffset(lightSize, lightSize)

        for _, band in ipairs(bands) do
            local spec = band.spec
            band.gradient.Offset = Vector2.new(math.sin(t * spec.speed + spec.phase) * 0.55, 0)
            band.gradient.Rotation = spec.rotation + math.sin(t * spec.speed * 0.8 + spec.phase) * 14
        end

        local area = Backdrop.AbsoluteSize
        local scale = math.max(WindowScale.Scale, 0.01)
        local decay = math.min(1, dt * 2.5)

        for _, spark in ipairs(sparks) do
            spark.y = spark.y - spark.speed * dt * (1 + Fx.energy * 2)
            if spark.y < -0.04 then
                spark.y = 1.04
                spark.x = rng:NextNumber()
                spark.ox, spark.oy = 0, 0
            end

            if presence > 0.05 then
                local dx = (spark.x - pointer.X) * area.X / scale + spark.ox
                local dy = (spark.y - pointer.Y) * area.Y / scale + spark.oy
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < 90 and distance > 0.001 then
                    local push = (90 - distance) * dt * 5 * presence
                    spark.ox = spark.ox + dx / distance * push
                    spark.oy = spark.oy + dy / distance * push
                end
            end
            spark.ox = spark.ox - spark.ox * decay * 0.4
            spark.oy = spark.oy - spark.oy * decay * 0.4

            spark.dot.Position = UDim2.new(
                spark.x + math.sin(t * spark.drift + spark.phase) * 0.02, spark.ox,
                spark.y, spark.oy
            )
            spark.dot.BackgroundTransparency = 0.25 + 0.65 * (0.5 + 0.5 * math.sin(t * 2.2 + spark.phase))
        end

        flash.BackgroundTransparency = 1 - Fx.flash * 0.16
    end)
end

do
    local rim = frame(Window, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1 })
    corner(rim, 22)
    local stroke = outline(rim, WHITE, 1.5, 0)
    local rimGradient = gradient(stroke, ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, LILAC),
        ColorSequenceKeypoint.new(0.50, ORCHID),
        ColorSequenceKeypoint.new(1.00, PURPLE),
    }), 0, fade({ { 0, 0.35 }, { 0.5, 0.8 }, { 1, 0.5 } }))

    animate(function(t)
        if Fx.enabled and Window.Visible then rimGradient.Rotation = (t * 36) % 360 end
    end)
end

local Header = frame(Window, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 64),
    Active = true,
    ZIndex = 2,
})

do
    local halo = softOrb(Header, PURPLE, 70, 0.28)
    halo.Position = UDim2.fromOffset(33, 32)

    local logo = frame(Header, { Position = UDim2.fromOffset(16, 15), Size = UDim2.fromOffset(34, 34), ZIndex = 2 })
    corner(logo, 11)
    local logoGradient = gradient(logo, ACCENT_GRADIENT, 45)

    local gloss = frame(logo, { Size = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 0.6 })
    corner(gloss, 11)
    gradient(gloss, ColorSequence.new(WHITE), 90, fade({ { 0, 0.2 }, { 1, 1 } }))

    local glyph = label(logo, 17, "black", WHITE)
    glyph.Size = UDim2.fromScale(1, 1)
    glyph.TextXAlignment = Enum.TextXAlignment.Center
    glyph.Text = "H"
    glyph.ZIndex = 2

    local title = label(Header, 17, "black", WHITE)
    title.Position = UDim2.fromOffset(60, 13)
    title.Size = UDim2.fromOffset(0, 20)
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Text = "huy pham"
    table.insert(Fx.shines, gradient(title, SHINE_GRADIENT, 0))

    local subtitle = label(Header, 10, false, DIM)
    subtitle.Position = UDim2.fromOffset(60, 34)
    subtitle.Size = UDim2.fromOffset(240, 14)
    subtitle.Text = "leak hub  ·  v1.4"

    animate(function(t)
        if not Window.Visible then return end
        logoGradient.Rotation = (t * 45) % 360
        local pulse = 70 + math.sin(t * 2.1) * 8
        halo.Size = UDim2.fromOffset(pulse, pulse)
    end)
end

local Pill = frame(Header, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -88, 0, 19),
    Size = UDim2.fromOffset(118, 26),
    BackgroundColor3 = SURFACE_3,
    BackgroundTransparency = 0.15,
})
round(Pill)
outline(Pill, STROKE, 1, 0)

local PillPulse = frame(Pill, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(15, 13),
    Size = UDim2.fromOffset(7, 7),
    BackgroundColor3 = COLORS.down,
})
round(PillPulse)

local PillDot = frame(Pill, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(15, 13),
    Size = UDim2.fromOffset(7, 7),
    BackgroundColor3 = COLORS.down,
    ZIndex = 2,
})
round(PillDot)

local PillText = label(Pill, 9, true, DIM)
PillText.Position = UDim2.fromOffset(27, 0)
PillText.Size = UDim2.new(1, -34, 1, 0)
PillText.TextTruncate = Enum.TextTruncate.AtEnd
PillText.Text = "DOWN"

animate(function(t)
    if not Window.Visible then return end
    local phase = (t * 0.8) % 1
    local size = 7 + phase * 14
    PillPulse.Size = UDim2.fromOffset(size, size)
    PillPulse.BackgroundTransparency = 0.35 + phase * 0.65
end)

local function headerButton(glyph, offsetX, callback)
    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(1, 0)
    button.Position = UDim2.new(1, offsetX, 0, 19)
    button.Size = UDim2.fromOffset(26, 26)
    button.BackgroundColor3 = SURFACE_3
    button.BackgroundTransparency = 0.15
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.TextColor3 = DIM
    button.Text = glyph
    button.Parent = Header
    round(button)
    outline(button, STROKE, 1, 0)

    local scale = Instance.new("UIScale")
    scale.Parent = button

    button.MouseEnter:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = PURPLE, BackgroundTransparency = 0, TextColor3 = WHITE })
        tween(scale, 0.3, { Scale = 1.1 }, Enum.EasingStyle.Back)
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.22, { BackgroundColor3 = SURFACE_3, BackgroundTransparency = 0.15, TextColor3 = DIM })
        tween(scale, 0.22, { Scale = 1 })
    end)
    button.MouseButton1Down:Connect(function() tween(scale, 0.1, { Scale = 0.9 }) end)
    button.MouseButton1Up:Connect(function() tween(scale, 0.3, { Scale = 1.1 }, Enum.EasingStyle.Back) end)
    button.MouseButton1Click:Connect(callback)

    return button
end

do
    local divider = frame(Window, {
        Position = UDim2.fromOffset(18, 64),
        Size = UDim2.new(1, -36, 0, 1),
        ZIndex = 2,
    })
    local dividerGradient = gradient(divider, ACCENT_GRADIENT, 0, fade({ { 0, 1 }, { 0.5, 0.6 }, { 1, 1 } }))

    animate(function(t)
        if Fx.enabled and Window.Visible then
            dividerGradient.Offset = Vector2.new(math.sin(t * 0.6) * 0.35, 0)
        end
    end)
end

local Sidebar = frame(Window, {
    Position = UDim2.fromOffset(16, 76),
    Size = UDim2.new(0, 140, 1, -92),
    BackgroundColor3 = CARD,
    BackgroundTransparency = 0.3,
    ZIndex = 2,
})
corner(Sidebar, 16)
outline(Sidebar, STROKE, 1, 0)

local TAB_HEIGHT, TAB_GAP = 28, 3

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel = 0
TabScroll.Size = UDim2.fromScale(1, 1)
TabScroll.CanvasSize = UDim2.new()
TabScroll.ScrollBarThickness = 2
TabScroll.ScrollBarImageColor3 = PURPLE
TabScroll.ScrollBarImageTransparency = 0.45
TabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
TabScroll.ZIndex = 2
TabScroll.Parent = Sidebar

local Indicator = frame(TabScroll, {
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.new(1, -16, 0, TAB_HEIGHT),
    BackgroundTransparency = 1,
    ZIndex = 2,
})

do
    local bloom = frame(Indicator, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 3),
        Size = UDim2.new(1, 8, 1, 8),
        BackgroundColor3 = PURPLE,
        BackgroundTransparency = 0.84,
        ZIndex = 1,
    })
    corner(bloom, 14)

    local pill = frame(Indicator, { Size = UDim2.fromScale(1, 1), ZIndex = 2 })
    corner(pill, 11)
    local pillGradient = gradient(pill, ACCENT_GRADIENT, 0)

    local gloss = frame(pill, { Size = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 0.82 })
    corner(gloss, 11)

    animate(function(t)
        if not (Fx.enabled and Window.Visible) then return end
        pillGradient.Rotation = math.sin(t * 0.7) * 25
        bloom.BackgroundTransparency = 0.9 + math.sin(t * 2) * 0.03
    end)
end


local Content = frame(Window, {
    Position = UDim2.fromOffset(168, 76),
    Size = UDim2.new(1, -184, 1, -92),
    BackgroundColor3 = CARD,
    BackgroundTransparency = 0.3,
    ZIndex = 2,
})
corner(Content, 16)
outline(Content, STROKE, 1, 0)

local Toast = { serial = 0 }
do
    local holder = nil
    local ok = pcall(function() holder = Instance.new("CanvasGroup") end)
    if not ok or not holder then holder = Instance.new("Frame") end
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -18, 0, 78)
    holder.Size = UDim2.fromOffset(240, 54)
    holder.BackgroundColor3 = SURFACE_2
    holder.BorderSizePixel = 0
    holder.Visible = false
    holder.ZIndex = 20
    holder.Parent = Window
    corner(holder, 14)
    outline(holder, PURPLE, 1, 0.45)

    local icon = frame(holder, { Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(32, 32) })
    corner(icon, 10)
    gradient(icon, ACCENT_GRADIENT, 45)

    local iconText = label(icon, 10, "black", WHITE)
    iconText.Size = UDim2.fromScale(1, 1)
    iconText.TextXAlignment = Enum.TextXAlignment.Center

    local heading = label(holder, 9, true, LILAC)
    heading.Position = UDim2.fromOffset(53, 11)
    heading.Size = UDim2.new(1, -64, 0, 12)

    local body = label(holder, 11, true, INK)
    body.Position = UDim2.fromOffset(53, 25)
    body.Size = UDim2.new(1, -64, 0, 16)
    body.TextTruncate = Enum.TextTruncate.AtEnd

    local progress = frame(holder, { Position = UDim2.new(0, 12, 1, -5), Size = UDim2.new(1, -24, 0, 2) })
    round(progress)
    gradient(progress, ACCENT_GRADIENT, 0)

    local SHOWN_AT, HIDDEN_AT = UDim2.new(1, -18, 0, 78), UDim2.new(1, 0, 0, 78)

    function Toast.show(headingText, bodyText, badge)
        if not Window.Visible or not Content.Visible then return end

        Toast.serial = Toast.serial + 1
        local serial = Toast.serial

        heading.Text = string.upper(headingText or "")
        body.Text = bodyText or ""
        iconText.Text = badge or "!"

        if not holder.Visible then
            holder.Position = HIDDEN_AT
            pcall(function() holder.GroupTransparency = 1 end)
        end
        holder.Visible = true
        tween(holder, 0.5, { Position = SHOWN_AT }, Enum.EasingStyle.Back)
        tween(holder, 0.3, { GroupTransparency = 0 })

        progress.Size = UDim2.new(1, -24, 0, 2)
        tween(progress, 2.8, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

        task.delay(2.9, function()
            if serial ~= Toast.serial then return end
            tween(holder, 0.3, { Position = HIDDEN_AT }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tween(holder, 0.25, { GroupTransparency = 1 })
            task.delay(0.32, function()
                if serial == Toast.serial then holder.Visible = false end
            end)
        end)
    end
end


local TabCursor = 8
local TabGroups = 0

local function newGroup(titleText)
    TabGroups = TabGroups + 1
    if TabGroups > 1 then
        local rule = frame(TabScroll, {
            Position = UDim2.fromOffset(14, TabCursor + 3),
            Size = UDim2.new(1, -28, 0, 1),
            ZIndex = 3,
        })
        gradient(rule, ACCENT_GRADIENT, 0, fade({ { 0, 0.75 }, { 0.5, 0.55 }, { 1, 1 } }))
        TabCursor = TabCursor + 8
    end

    local head = label(TabScroll, 9, true, LILAC)
    head.Position = UDim2.fromOffset(16, TabCursor + 2)
    head.Size = UDim2.new(1, -24, 0, 12)
    head.TextTransparency = 0.2
    head.ZIndex = 3
    head.Text = string.upper(titleText)

    TabCursor = TabCursor + 18
end

local Pages = {}
local Tabs = {}
local currentTab = nil
local activate = nil

local function newPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Position = UDim2.fromOffset(10, 10)
    page.Size = UDim2.new(1, -20, 1, -20)
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = PURPLE
    page.ScrollBarImageTransparency = 0.45
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    pad(page, 1, 8, 1, 10)

    Pages[name] = page
    return page
end

local function newTab(name, order)
    local y = TabCursor
    TabCursor = TabCursor + TAB_HEIGHT + TAB_GAP

    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.fromOffset(8, y)
    button.Size = UDim2.new(1, -16, 0, TAB_HEIGHT)
    button.BackgroundColor3 = SURFACE_3
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 3
    button.Parent = TabScroll
    corner(button, 11)

    local marker = frame(button, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = LILAC,
    })
    round(marker)

    local text = label(button, 12, false, DIM)
    text.Position = UDim2.fromOffset(30, 0)
    text.Size = UDim2.new(1, -36, 1, 0)
    text.Text = name

    Tabs[name] = { button = button, marker = marker, text = text, y = y, page = newPage(name) }
    TabScroll.CanvasSize = UDim2.fromOffset(0, y + TAB_HEIGHT + 8)

    button.MouseEnter:Connect(function()
        if currentTab == name then return end
        tween(button, 0.18, { BackgroundTransparency = 0.45 })
        tween(text, 0.18, { TextColor3 = LILAC, Position = UDim2.fromOffset(33, 0) })
    end)
    button.MouseLeave:Connect(function()
        if currentTab == name then return end
        tween(button, 0.22, { BackgroundTransparency = 1 })
        tween(text, 0.22, { TextColor3 = DIM, Position = UDim2.fromOffset(30, 0) })
    end)
    button.MouseButton1Click:Connect(function()
        if activate then activate(name) end
    end)

    return Tabs[name].page
end

activate = function(name)
    local previousTab = currentTab
    currentTab = name

    for key, tab in pairs(Tabs) do
        local active = (key == name)
        tab.page.Visible = active
        tab.text.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium

        tween(tab.button, 0.2, { BackgroundTransparency = 1 })
        tween(tab.text, 0.25, {
            TextColor3 = active and WHITE or DIM,
            Position = UDim2.fromOffset(active and 32 or 30, 0),
        })
        tween(tab.marker, 0.35, {
            BackgroundColor3 = active and WHITE or LILAC,
            Size = active and UDim2.fromOffset(8, 8) or UDim2.fromOffset(6, 6),
        }, Enum.EasingStyle.Back)

        if active then
            tween(Indicator, 0.45, { Position = UDim2.fromOffset(8, tab.y) })
            if previousTab ~= name then
                tab.page.Position = UDim2.fromOffset(10, 26)
                tween(tab.page, 0.45, { Position = UDim2.fromOffset(10, 10) })
            end
        end
    end
end


local UI = {}

local function ripple(host, color, centred)
    pcall(function()
        local origin, size = host.AbsolutePosition, host.AbsoluteSize
        local x, y = size.X / 2, size.Y / 2

        if not centred then
            local mouse = userInputService:GetMouseLocation()
            local mx, my = mouse.X - origin.X, mouse.Y - origin.Y
            if mx >= 0 and my >= 0 and mx <= size.X and my <= size.Y then x, y = mx, my end
        end

        local scale = math.max(WindowScale.Scale, 0.01)
        local diameter = math.max(size.X, size.Y) * 2.4 / scale

        local dot = frame(host, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(x / scale, y / scale),
            Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = color or PURPLE,
            BackgroundTransparency = 0.75,
            ZIndex = 0,
        })
        round(dot)

        tween(dot, 0.6, { Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1 },
            Enum.EasingStyle.Quad)
        task.delay(0.65, function() pcall(function() dot:Destroy() end) end)
    end)
end

local function card(page, height)
    local item = frame(page, {
        Size = UDim2.new(1, -2, 0, height),
        BackgroundColor3 = CARD,
        BackgroundTransparency = GLASS,
        ClipsDescendants = true,
        LayoutOrder = nextOrder(),
    })
    corner(item, 13)

    local stroke = outline(item, WHITE, 1, 0)
    gradient(stroke, ColorSequence.new(Color3.fromRGB(98, 86, 138), STROKE), 90)

    return item, stroke
end

local function hoverable(row, hit, stroke)
    hit.MouseEnter:Connect(function()
        tween(row, 0.18, { BackgroundTransparency = GLASS_HI, BackgroundColor3 = CARD_HI })
        if stroke then tween(stroke, 0.18, { Color = LILAC }) end
    end)
    hit.MouseLeave:Connect(function()
        tween(row, 0.3, { BackgroundTransparency = GLASS, BackgroundColor3 = CARD })
        if stroke then tween(stroke, 0.3, { Color = WHITE }) end
    end)
end

function UI.section(page, titleText)
    local holder = frame(page, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -2, 0, 22),
        LayoutOrder = nextOrder(),
    })

    local dot = frame(holder, {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(6, 6),
    })
    round(dot)
    gradient(dot, ACCENT_GRADIENT, 45)

    local text = label(holder, 10, true, LILAC)
    text.Position = UDim2.fromOffset(16, 0)
    text.Size = UDim2.new(0, 0, 1, 0)
    text.AutomaticSize = Enum.AutomaticSize.X
    text.Text = string.upper(titleText)

    local line = frame(holder, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(1, -120, 0, 1),
    })
    gradient(line, ACCENT_GRADIENT, 0, fade({ { 0, 0.55 }, { 1, 1 } }))

    local function fit()
        line.Size = UDim2.new(1, -(text.AbsoluteSize.X / math.max(WindowScale.Scale, 0.01) + 30), 0, 1)
    end
    text:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
    task.defer(fit)

    return holder
end

function UI.button(page, opt)
    local hasDesc = opt.desc ~= nil and opt.desc ~= ""
    local row, stroke = card(page, hasDesc and 52 or 40)

    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.fromScale(1, 1)
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 3
    hit.Parent = row

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, hasDesc and 10 or 0)
    title.Size = UDim2.new(1, -56, 0, hasDesc and 16 or 40)
    title.Text = opt.name
    title.TextTruncate = Enum.TextTruncate.AtEnd

    if hasDesc then
        local desc = label(row, 10, false, DIM)
        desc.Position = UDim2.fromOffset(14, 28)
        desc.Size = UDim2.new(1, -56, 0, 14)
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Text = opt.desc
    end

    local badge = frame(row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = MIST,
    })
    round(badge)

    local chevron = label(badge, 15, true, LILAC)
    chevron.Size = UDim2.fromScale(1, 1)
    chevron.Position = UDim2.fromOffset(1, -1)
    chevron.TextXAlignment = Enum.TextXAlignment.Center
    chevron.Text = "›"

    hoverable(row, hit, stroke)
    hit.MouseEnter:Connect(function()
        tween(badge, 0.25, { BackgroundColor3 = PURPLE, Position = UDim2.new(1, -9, 0.5, 0) })
        tween(chevron, 0.25, { TextColor3 = WHITE })
    end)
    hit.MouseLeave:Connect(function()
        tween(badge, 0.3, { BackgroundColor3 = MIST, Position = UDim2.new(1, -12, 0.5, 0) })
        tween(chevron, 0.3, { TextColor3 = LILAC })
    end)

    hit.MouseButton1Click:Connect(function()
        ripple(row, PURPLE)
        if opt.callback then pcall(opt.callback) end
    end)

    return row
end

function UI.label(page, value, muted)
    local holder = frame(page, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -2, 0, 16),
        LayoutOrder = nextOrder(),
    })

    local text = label(holder, 10, false, muted and DIM or INK)
    text.Position = UDim2.fromOffset(4, 0)
    text.Size = UDim2.new(1, -8, 1, 0)
    text.Text = value

    return text
end

function UI.toggle(page, opt)
    local row, stroke = card(page, 52)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, opt.desc and 10 or 0)
    title.Size = UDim2.new(1, -84, 0, opt.desc and 16 or 52)
    title.Text = opt.name
    title.TextTruncate = Enum.TextTruncate.AtEnd

    if opt.desc then
        local desc = label(row, 10, false, DIM)
        desc.Position = UDim2.fromOffset(14, 28)
        desc.Size = UDim2.new(1, -84, 0, 14)
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Text = opt.desc
    end

    local track = frame(row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(46, 26),
        BackgroundColor3 = MIST,
    })
    round(track)

    local fill = frame(track, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
    round(fill)
    gradient(fill, ACCENT_GRADIENT, 0)

    local knob = frame(track, {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 2,
    })
    round(knob)
    outline(knob, STROKE, 1, 0)

    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.fromScale(1, 1)
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 3
    hit.Parent = row

    hoverable(row, hit, stroke)

    local on = opt.value and true or false

    local function paint()
        tween(fill, 0.25, { BackgroundTransparency = on and 0 or 1 })
        tween(knob, 0.4, { Position = on and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) },
            Enum.EasingStyle.Back)
    end

    paint()

    hit.MouseButton1Click:Connect(function()
        on = not on
        paint()
        ripple(row, PURPLE)
        if opt.callback then pcall(opt.callback, on) end
    end)

    return {
        Set = function(_, value)
            on = value and true or false
            paint()
        end,
        Get = function() return on end,
    }
end

function UI.slider(page, opt)
    local row, stroke = card(page, 62)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, 11)
    title.Size = UDim2.new(1, -110, 0, 16)
    title.Text = opt.name

    local valuePill = frame(row, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 9),
        Size = UDim2.fromOffset(72, 20),
        BackgroundColor3 = MIST,
    })
    round(valuePill)

    local valueLabel = label(valuePill, 10, true, LILAC)
    valueLabel.Size = UDim2.fromScale(1, 1)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    local track = frame(row, {
        Position = UDim2.fromOffset(16, 42),
        Size = UDim2.new(1, -32, 0, 6),
        BackgroundColor3 = MIST,
    })
    round(track)

    local fill = frame(track, { Size = UDim2.new(0, 0, 1, 0) })
    round(fill)
    gradient(fill, ACCENT_GRADIENT, 0)

    local knob = frame(track, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = 2,
    })
    round(knob)
    outline(knob, PURPLE, 2, 0)

    local knobScale = Instance.new("UIScale")
    knobScale.Parent = knob

    local grab = frame(row, {
        Position = UDim2.fromOffset(8, 32),
        Size = UDim2.new(1, -16, 0, 26),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 3,
    })

    hoverable(row, row, stroke)

    local minimum, maximum = opt.min, opt.max
    local value = math.clamp(opt.value or minimum, minimum, maximum)
    local dragging = false

    local function paint()
        local alpha = (maximum == minimum) and 0 or (value - minimum) / (maximum - minimum)
        alpha = math.clamp(alpha, 0, 1)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = opt.format and opt.format(value) or tostring(value)
    end

    local function applyFromX(x)
        local alpha = (x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
        alpha = math.clamp(alpha, 0, 1)

        local raw = minimum + (maximum - minimum) * alpha
        if opt.increment and opt.increment > 0 then
            raw = math.floor(raw / opt.increment + 0.5) * opt.increment
        end

        local nextValue = math.clamp(raw, minimum, maximum)
        if nextValue ~= value then
            value = nextValue
            paint()
            if opt.callback then pcall(opt.callback, value) end
        end
    end

    grab.MouseEnter:Connect(function()
        if not dragging then tween(knobScale, 0.25, { Scale = 1.18 }, Enum.EasingStyle.Back) end
    end)
    grab.MouseLeave:Connect(function()
        if not dragging then tween(knobScale, 0.25, { Scale = 1 }) end
    end)

    grab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            tween(knobScale, 0.25, { Scale = 1.35 }, Enum.EasingStyle.Back)
            tween(valuePill, 0.2, { BackgroundColor3 = PURPLE })
            tween(valueLabel, 0.2, { TextColor3 = WHITE })
            applyFromX(input.Position.X)
        end
    end)

    bind(userInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            applyFromX(input.Position.X)
        end
    end)

    bind(userInputService.InputEnded, function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            tween(knobScale, 0.3, { Scale = 1 })
            tween(valuePill, 0.3, { BackgroundColor3 = MIST })
            tween(valueLabel, 0.3, { TextColor3 = LILAC })
        end
    end)

    paint()

    return {
        Set = function(_, newValue)
            value = math.clamp(newValue, minimum, maximum)
            paint()
        end,
    }
end

function UI.input(page, opt)
    local row = card(page, 56)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, 10)
    title.Size = UDim2.new(1, -160, 0, 16)
    title.Text = opt.name

    local desc = label(row, 10, false, DIM)
    desc.Position = UDim2.fromOffset(14, 28)
    desc.Size = UDim2.new(1, -160, 0, 14)
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    desc.Text = opt.desc or ""

    local box = Instance.new("TextBox")
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, -12, 0.5, 0)
    box.Size = UDim2.fromOffset(128, 32)
    box.BackgroundColor3 = SURFACE_2
    box.BackgroundTransparency = 0.15
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.TextColor3 = LILAC
    box.PlaceholderText = opt.placeholder or ""
    box.PlaceholderColor3 = DIM
    box.Text = opt.value or ""
    box.ClearTextOnFocus = false
    box.Parent = row
    corner(box, 10)
    pad(box, 10, 10)

    focusRing(box, outline(box, STROKE, 1, 0), row)

    box.FocusLost:Connect(function()
        if opt.callback then pcall(opt.callback, box.Text) end
    end)

    return {
        Set = function(_, value) box.Text = value end,
        Get = function() return box.Text end,
    }
end


local function setStatus(state, value)
    local color = COLORS[state] or COLORS.down
    local text = string.upper(value or state)
    if PillText.Text == text and PillDot.BackgroundColor3 == color then return end

    pcall(function()
        PillText.Text = text
        tween(PillText, 0.3, { TextColor3 = color })
        tween(PillDot, 0.3, { BackgroundColor3 = color })
        PillPulse.BackgroundColor3 = color
    end)
end


function UI.note(page, text, tone)
    local row = card(page, 40)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.Size = UDim2.new(1, -2, 0, 0)
    pad(row, 14, 14, 10, 10)

    local body = label(row, 10, false, tone or DIM)
    body.Size = UDim2.new(1, 0, 0, 0)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Text = text

    return body, row
end

function UI.status(page, text)
    local body = UI.note(page, text, INK)
    return function(value)
        local message = tostring(value)
        pcall(function() body.Text = message end)
        if string.find(message, "Đang", 1, true) then
            setStatus("middle", "working")
        elseif string.find(message, "✅", 1, true) or string.find(message, "✔", 1, true) then
            setStatus("up", "done")
        elseif string.find(message, "❌", 1, true) then
            setStatus("down", "failed")
        end
    end
end

function UI.roster(page, titleText, names)
    local row = card(page, 34 + #names * 20)

    local title = label(row, 12, true, WHITE)
    title.Position = UDim2.fromOffset(14, 8)
    title.Size = UDim2.new(1, -28, 0, 18)
    title.Text = titleText
    table.insert(Fx.shines, gradient(title, SHINE_GRADIENT, 0))

    for index, name in ipairs(names) do
        local entry = label(row, 11, true, INK)
        entry.Position = UDim2.fromOffset(24, 28 + (index - 1) * 20)
        entry.Size = UDim2.new(1, -40, 0, 18)
        entry.Text = "• " .. name
    end

    return row
end

function UI.dropdown(page, opt)
    local HEAD, ITEM = 44, 30
    local count = #opt.options
    local openHeight = HEAD + count * ITEM + 8
    local row, stroke = card(page, HEAD)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, 0)
    title.Size = UDim2.new(1, -56, 0, HEAD)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Text = opt.name

    local badge = frame(row, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, (HEAD - 26) / 2),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = MIST,
    })
    round(badge)

    local chevron = label(badge, 9, true, LILAC)
    chevron.Size = UDim2.fromScale(1, 1)
    chevron.TextXAlignment = Enum.TextXAlignment.Center
    chevron.Text = "▼"

    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.new(1, 0, 0, HEAD)
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 3
    hit.Parent = row

    hoverable(row, hit, stroke)

    local isOpen = false
    local function setOpen(state)
        isOpen = state
        tween(row, 0.3, { Size = UDim2.new(1, -2, 0, state and openHeight or HEAD) })
        tween(badge, 0.25, { BackgroundColor3 = state and PURPLE or MIST })
        chevron.Text = state and "▲" or "▼"
    end

    hit.MouseButton1Click:Connect(function()
        ripple(row, PURPLE)
        setOpen(not isOpen)
    end)

    local list = frame(row, {
        Position = UDim2.fromOffset(8, HEAD),
        Size = UDim2.new(1, -16, 0, count * ITEM),
        BackgroundTransparency = 1,
    })

    for index, option in ipairs(opt.options) do
        local item = Instance.new("TextButton")
        item.Position = UDim2.fromOffset(0, (index - 1) * ITEM)
        item.Size = UDim2.new(1, 0, 0, ITEM - 4)
        item.BackgroundColor3 = SURFACE_2
        item.BackgroundTransparency = 0.25
        item.BorderSizePixel = 0
        item.AutoButtonColor = false
        item.Font = Enum.Font.GothamMedium
        item.TextSize = 11
        item.TextColor3 = INK
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.Text = "   " .. option.name
        item.ZIndex = 3
        item.Parent = list
        corner(item, 9)

        if option.swatch then
            local swatch = frame(item, {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
            })
            swatch.BackgroundColor3 = option.swatch
            round(swatch)
            outline(swatch, STROKE, 1, 0)
        end

        item.MouseEnter:Connect(function()
            tween(item, 0.15, { BackgroundTransparency = 0.05, BackgroundColor3 = SURFACE_3 })
        end)
        item.MouseLeave:Connect(function()
            tween(item, 0.2, { BackgroundTransparency = 0.25, BackgroundColor3 = SURFACE_2 })
        end)
        item.MouseButton1Click:Connect(function()
            title.Text = opt.name .. ": " .. option.name
            setOpen(false)
            if opt.callback then pcall(opt.callback, option.name, option.value) end
        end)
    end

    return {
        Set = function(_, optionName)
            title.Text = opt.name .. ": " .. tostring(optionName)
        end,
    }
end


local UIState = { shown = true, minimized = false, width = WIDTH, height = HEIGHT, gripOn = true }

local function fitScale()
    local camera = workspace.CurrentCamera
    local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local fit = math.min((view.X - 24) / UIState.width, (view.Y - 24) / UIState.height, 1)
    return math.clamp(fit, 0.45, 1)
end

local Drag = { active = false, start = nil, origin = nil, target = nil }

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        Drag.active = true
        Drag.start = input.Position
        Drag.origin = Drag.target or Window.Position
        Drag.target = Drag.origin

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Drag.active = false
            end
        end)
    end
end)

bind(userInputService.InputChanged, function(input)
    if not Drag.active or not Drag.start or not Drag.origin then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - Drag.start
        Drag.target = UDim2.new(
            Drag.origin.X.Scale, Drag.origin.X.Offset + delta.X,
            Drag.origin.Y.Scale, Drag.origin.Y.Offset + delta.Y
        )
    end
end)

animate(function(_, dt)
    if not Drag.target then return end
    local current = Window.Position
    Window.Position = current:Lerp(Drag.target, math.min(1, dt * 20))

    if not Drag.active
        and math.abs(Window.Position.X.Offset - Drag.target.X.Offset) < 0.5
        and math.abs(Window.Position.Y.Offset - Drag.target.Y.Offset) < 0.5 then
        Window.Position = Drag.target
        Drag.target = nil
    end
end)

animate(function(t)
    Glow.Visible = Window.Visible
    if not Window.Visible then return end

    local scale = WindowScale.Scale
    Glow.Position = Window.Position
    Glow.Size = UDim2.fromOffset(Window.Size.X.Offset * scale, Window.Size.Y.Offset * scale)

    local pulse = Fx.enabled and math.sin(t * 1.6) * 0.012 or 0
    for index, layer in ipairs(GlowLayers) do
        layer.BackgroundTransparency = 0.935 + index * 0.008 - pulse - Fx.energy * 0.02
    end
end)

animate(function(t)
    if not Window.Visible or not Fx.enabled then return end
    local offset = ((t * 0.32) % 2.6) - 1.3
    for _, shine in ipairs(Fx.shines) do
        shine.Offset = Vector2.new(offset, 0)
    end
end)

local Grip = Instance.new("TextButton")
Grip.AnchorPoint = Vector2.new(1, 1)
Grip.Position = UDim2.new(1, -5, 1, -5)
Grip.Size = UDim2.fromOffset(18, 18)
Grip.BackgroundTransparency = 1
Grip.AutoButtonColor = false
Grip.Text = ""
Grip.ZIndex = 8
Grip.Parent = Window

do
    local dots = {}
    for index, spot in ipairs({ { 14, 14 }, { 9, 14 }, { 14, 9 }, { 4, 14 }, { 9, 9 }, { 14, 4 } }) do
        local dot = frame(Grip, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(spot[1], spot[2]),
            Size = UDim2.fromOffset(3, 3),
            BackgroundColor3 = LILAC,
        })
        round(dot)
        dots[index] = dot
    end

    local function paintDots(color)
        for _, dot in ipairs(dots) do tween(dot, 0.18, { BackgroundColor3 = color }) end
    end

    local Resize = { active = false }

    Grip.MouseEnter:Connect(function() paintDots(PURPLE) end)
    Grip.MouseLeave:Connect(function() if not Resize.active then paintDots(LILAC) end end)

    Grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Resize.active = true
            Resize.start = input.Position
            Resize.size = Vector2.new(Window.Size.X.Offset, Window.Size.Y.Offset)
            Resize.origin = Drag.target or Window.Position
            Drag.target = nil
            Window.Position = Resize.origin
        end
    end)

    bind(userInputService.InputChanged, function(input)
        if not Resize.active then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local scaleNow = math.max(WindowScale.Scale, 0.01)
            local delta = (input.Position - Resize.start) / scaleNow
            local width = math.clamp(Resize.size.X + delta.X, 520, 980)
            local height = math.clamp(Resize.size.Y + delta.Y, 400, 760)

            Window.Size = UDim2.fromOffset(width, height)
            Window.Position = UDim2.new(
                Resize.origin.X.Scale, Resize.origin.X.Offset + (width - Resize.size.X) / 2 * scaleNow,
                Resize.origin.Y.Scale, Resize.origin.Y.Offset + (height - Resize.size.Y) / 2 * scaleNow
            )
            UIState.width, UIState.height = width, height
        end
    end)

    bind(userInputService.InputEnded, function(input)
        if not Resize.active then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Resize.active = false
            paintDots(LILAC)
        end
    end)
end

local function setMinimized(state)
    UIState.minimized = state
    if state then
        Sidebar.Visible = false
        Content.Visible = false
        Grip.Visible = false
        tween(Window, 0.4, { Size = UDim2.fromOffset(UIState.width, 66) })
    else
        tween(Window, 0.45, { Size = UDim2.fromOffset(UIState.width, UIState.height) })
        task.delay(0.12, function()
            if not UIState.minimized then
                Sidebar.Visible = true
                Content.Visible = true
                Grip.Visible = UIState.gripOn
            end
        end)
    end
end

local Reopen = Instance.new("TextButton")
Reopen.AnchorPoint = Vector2.new(0.5, 0.5)
Reopen.Position = UDim2.fromOffset(42, 42)
Reopen.Size = UDim2.fromOffset(46, 46)
Reopen.BackgroundColor3 = WHITE
Reopen.BorderSizePixel = 0
Reopen.AutoButtonColor = false
Reopen.Font = Enum.Font.GothamBlack
Reopen.TextSize = 19
Reopen.TextColor3 = WHITE
Reopen.Text = "H"
Reopen.Visible = false
Reopen.ZIndex = 3
Reopen.Parent = Screen
round(Reopen)
outline(Reopen, WHITE, 1.5, 0.3)

do
    local reopenGradient = gradient(Reopen, ACCENT_GRADIENT, 45)
    local reopenScale = Instance.new("UIScale")
    reopenScale.Parent = Reopen

    local halo = softOrb(Screen, PURPLE, 96, 0.3)
    halo.Position = Reopen.Position
    halo.ZIndex = 2
    halo.Visible = false

    UIState.reopenScale = reopenScale

    Reopen.MouseEnter:Connect(function() tween(reopenScale, 0.3, { Scale = 1.1 }, Enum.EasingStyle.Back) end)
    Reopen.MouseLeave:Connect(function() tween(reopenScale, 0.25, { Scale = 1 }) end)

    animate(function(t)
        halo.Visible = Reopen.Visible
        if not Reopen.Visible then return end
        reopenGradient.Rotation = (t * 60) % 360
        local size = 92 + math.sin(t * 2.4) * 10
        halo.Size = UDim2.fromOffset(size, size)
    end)
end

local function showWindow(visible)
    UIState.shown = visible

    if visible then
        Reopen.Visible = false
        Window.Visible = true
        WindowScale.Scale = fitScale() * 0.9
        tween(WindowScale, 0.5, { Scale = fitScale() }, Enum.EasingStyle.Back)
    else
        tween(WindowScale, 0.18, { Scale = fitScale() * 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.18, function()
            if UIState.shown then return end
            Window.Visible = false
            Reopen.Visible = true
            UIState.reopenScale.Scale = 0.4
            tween(UIState.reopenScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
        end)
    end
end

headerButton("×", -16, function()
    showWindow(false)
end)

headerButton("–", -48, function()
    setMinimized(not UIState.minimized)
end)

Reopen.MouseButton1Click:Connect(function()
    showWindow(true)
end)

bind(userInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        showWindow(not UIState.shown)
    end
end)

bind(runService.Heartbeat, function(dt)
    Fx.clock = Fx.clock + dt
    local t = Fx.clock
    for index = #Fx.animators, 1, -1 do
        local ok, done = pcall(Fx.animators[index], t, dt)
        if not ok or done then table.remove(Fx.animators, index) end
    end
end)


newGroup("copy")
local CopyPage     = newTab("Copy", 1)
local LoadPage     = newTab("Load", 2)

newGroup("leak")
local LeakPage     = newTab("Leak PC", 3)
local ScriptPage   = newTab("Script", 4)
local MapPage      = newTab("Map", 5)
local GuiPage      = newTab("Gui", 6)
local AvatarPage   = newTab("Avatar", 7)
local VFXPage      = newTab("VFX", 8)
local MediaPage    = newTab("Media", 9)

newGroup("scan")
local RemotePage   = newTab("Remote", 10)
local SpyPage      = newTab("Spy", 11)
local DiscoverPage = newTab("Discover", 12)
local ClonePage    = newTab("Clone", 13)

newGroup("hub")
local SettingPage  = newTab("Setting", 14)
local AdminPage    = newTab("Admin", 15)

local refreshLoad

-- ================== MODAL ==================
local function openModal(width, height, titleText)
    local overlay = frame(Window, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 30,
    })
    corner(overlay, 22)
    tween(overlay, 0.25, { BackgroundTransparency = 0.4 })

    local dialog = frame(overlay, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = SURFACE_2,
        ZIndex = 31,
    })
    corner(dialog, 16)
    outline(dialog, PURPLE, 1.2, 0.2)

    local dialogScale = Instance.new("UIScale")
    dialogScale.Scale = 0.9
    dialogScale.Parent = dialog
    tween(dialogScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)

    local heading = label(dialog, 13, true, WHITE)
    heading.Position = UDim2.fromOffset(16, 14)
    heading.Size = UDim2.new(1, -32, 0, 18)
    heading.TextTruncate = Enum.TextTruncate.AtEnd
    heading.Text = titleText

    local function close()
        pcall(function() overlay:Destroy() end)
    end

    return overlay, dialog, heading, close
end

local function modalButton(parent, text, primary, position, size)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = primary and PURPLE or SURFACE_3
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.TextColor3 = WHITE
    button.Text = text
    button.ZIndex = 32
    button.Parent = parent
    corner(button, 10)
    button.MouseEnter:Connect(function() tween(button, 0.15, { BackgroundTransparency = 0.12 }) end)
    button.MouseLeave:Connect(function() tween(button, 0.2, { BackgroundTransparency = 0 }) end)
    return button
end

local function modalBox(parent, position, size, text, placeholder, color)
    local box = Instance.new("TextBox")
    box.Position = position
    box.Size = size
    box.BackgroundColor3 = SURFACE_3
    box.BackgroundTransparency = 0.15
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.TextColor3 = color or LILAC
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = DIM
    box.Text = text or ""
    box.ClearTextOnFocus = false
    box.ZIndex = 32
    box.Parent = parent
    corner(box, 10)
    pad(box, 10, 10)
    focusRing(box, outline(box, STROKE, 1, 0), nil)
    return box
end

-- ================== MODAL SAVE (đặt tên mục copy) ==================
local function f25(defaultName, category, produce)
    local _, dialog, heading, close = openModal(300, 156, "Đặt tên mục copy")

    local box = modalBox(dialog, UDim2.fromOffset(16, 48), UDim2.new(1, -32, 0, 34), defaultName, "tên mục...")

    local cancel = modalButton(dialog, "Hủy", false, UDim2.new(0, 16, 1, -46), UDim2.new(0.5, -22, 0, 32))
    local accept = modalButton(dialog, "Chấp Nhận", true, UDim2.new(0.5, 6, 1, -46), UDim2.new(0.5, -22, 0, 32))

    cancel.MouseButton1Click:Connect(close)

    local busy = false
    accept.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true

        local name = box.Text
        if name == "" then name = defaultName end
        heading.Text = "⏳ Đang lưu..."

        task.spawn(function()
            local saved = false
            local ok, data = pcall(produce)
            if ok and data then
                local ok2, res = pcall(f14, name, category, data)
                saved = ok2 and res and true or false
            end

            close()
            if saved then
                Toast.show("đã lưu", name, "✓")
            else
                Toast.show("lưu thất bại", name, "!")
            end
            refreshLoad()
        end)
    end)
end

-- ================== MODAL LOAD (có PREVIEW) ==================
local function openPreview(record)
    local savedData = f17(record.FileName)
    if not savedData then
        Toast.show("lỗi", "Không đọc được file: " .. tostring(record.Name), "!")
        return
    end

    local stats = analyzeSavedData(savedData)
    local _, dialog, _, close = openModal(320, 372, "🔍 Preview: " .. tostring(record.Name))

    local sub = label(dialog, 10, false, DIM)
    sub.Position = UDim2.fromOffset(16, 36)
    sub.Size = UDim2.new(1, -32, 0, 14)
    sub.TextTruncate = Enum.TextTruncate.AtEnd
    sub.Text = "[" .. tostring(record.Category or "Data") .. "] — " .. tostring(stats.Total) .. " instance"

    local statsFrame = frame(dialog, {
        Position = UDim2.fromOffset(16, 58),
        Size = UDim2.new(1, -32, 0, 188),
        BackgroundColor3 = SURFACE_3,
        BackgroundTransparency = 0.2,
        ZIndex = 32,
    })
    corner(statsFrame, 12)
    outline(statsFrame, STROKE, 1, 0)

    local statsLayout = Instance.new("UIListLayout")
    statsLayout.Padding = UDim.new(0, 2)
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Parent = statsFrame
    pad(statsFrame, 12, 12, 8, 8)

    local statList = {
        { "🧱 Parts", stats.Parts, Color3.fromRGB(200, 200, 220) },
        { "🛠️ Tools", stats.Tools, Color3.fromRGB(100, 200, 255) },
        { "🖼️ Gui", stats.Gui, Color3.fromRGB(255, 150, 220) },
        { "📜 Scripts", stats.Scripts, Color3.fromRGB(255, 200, 100) },
        { "✨ VFX", stats.VFX, Color3.fromRGB(220, 150, 255) },
        { "🎬 Anim", stats.Anim, Color3.fromRGB(255, 100, 180) },
        { "🔗 Remote", stats.Remote, Color3.fromRGB(100, 220, 240) },
        { "🔊 Sounds", stats.Sounds, Color3.fromRGB(150, 255, 150) },
        { "💡 Lights", stats.Lights, Color3.fromRGB(255, 240, 130) },
        { "📦 Khác", stats.Other, Color3.fromRGB(180, 180, 180) },
    }
    for index, info in ipairs(statList) do
        local row = label(statsFrame, 10, false, info[3])
        row.Size = UDim2.new(1, 0, 0, 15)
        row.LayoutOrder = index
        row.Text = info[1] .. ": " .. tostring(info[2])
    end

    if stats.HasScript then
        local warn = frame(dialog, {
            Position = UDim2.fromOffset(16, 252),
            Size = UDim2.new(1, -32, 0, 22),
            BackgroundColor3 = Color3.fromRGB(86, 66, 24),
            BackgroundTransparency = 0.35,
            ZIndex = 32,
        })
        corner(warn, 8)
        local warnText = label(warn, 9, true, Color3.fromRGB(255, 220, 120))
        warnText.Size = UDim2.fromScale(1, 1)
        warnText.TextXAlignment = Enum.TextXAlignment.Center
        warnText.Text = "⚠️ Có script — cần decompile"
    end

    local scaleBox = modalBox(dialog, UDim2.fromOffset(16, 286), UDim2.fromOffset(90, 30), "1", "Scale", Color3.fromRGB(110, 235, 170))

    local scaleHint = label(dialog, 10, false, DIM)
    scaleHint.Position = UDim2.fromOffset(116, 286)
    scaleHint.Size = UDim2.new(1, -132, 0, 30)
    scaleHint.Text = "← Tỉ lệ Scale"

    local cancel = modalButton(dialog, "Hủy", false, UDim2.new(0, 16, 1, -46), UDim2.new(0.5, -22, 0, 32))
    local load = modalButton(dialog, "✔ Load ngay", true, UDim2.new(0.5, 6, 1, -46), UDim2.new(0.5, -22, 0, 32))

    cancel.MouseButton1Click:Connect(close)

    load.MouseButton1Click:Connect(function()
        local scaleVal = tonumber(scaleBox.Text) or 1
        local target = ({
            Tools = starterPack,
            Gui = starterGui,
            Nametag = starterGui,
            ReplicatedStorage = replicatedStorage,
            Lighting = lighting,
            Map = workspace,
            All = workspace,
            VFX = workspace,
            Media = workspace,
            Remote = workspace,
            Spy = workspace,
            Discover = workspace,
            Clone = workspace,
        })[record.Category] or workspace

        local folderName = "📁_Loaded_" .. tostring(record.Name)
        local existing = target:FindFirstChild(folderName)
        if existing then existing:Destroy() end

        local folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = target

        for _, entry in ipairs(savedData) do
            local ok, inst = pcall(f10, entry, scaleVal)
            if ok and inst then inst.Parent = folder end
        end

        close()
        Toast.show("đã load", tostring(record.Name), "✓")
    end)
end

-- ================== LOAD LIST ==================
local loadRows = {}
local emptyRow = nil

function refreshLoad()
    for _, row in ipairs(loadRows) do
        pcall(function() row:Destroy() end)
    end
    loadRows = {}

    local list = f11()
    if emptyRow then emptyRow.Visible = (#list == 0) end

    for _, record in ipairs(list) do
        local row, stroke = card(LoadPage, 46)
        table.insert(loadRows, row)

        local bar = frame(row, {
            Position = UDim2.fromOffset(9, 11),
            Size = UDim2.new(0, 3, 1, -22),
        })
        round(bar)
        gradient(bar, ACCENT_GRADIENT, 90)

        local title = label(row, 12, true, INK)
        title.Position = UDim2.fromOffset(22, 7)
        title.Size = UDim2.new(1, -112, 0, 16)
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.Text = "📁 " .. tostring(record.Name)

        local body = label(row, 10, false, DIM)
        body.Position = UDim2.fromOffset(22, 24)
        body.Size = UDim2.new(1, -112, 0, 14)
        body.TextTruncate = Enum.TextTruncate.AtEnd
        body.Text = "[" .. tostring(record.Category or "Data") .. "]" .. (record.Time and ("  ·  " .. tostring(record.Time)) or "")

        local hit = Instance.new("TextButton")
        hit.BackgroundTransparency = 1
        hit.Size = UDim2.new(1, -84, 1, 0)
        hit.Text = ""
        hit.AutoButtonColor = false
        hit.ZIndex = 3
        hit.Parent = row
        hoverable(row, hit, stroke)

        local lock = Instance.new("TextButton")
        lock.AnchorPoint = Vector2.new(1, 0.5)
        lock.Position = UDim2.new(1, -46, 0.5, 0)
        lock.Size = UDim2.fromOffset(28, 28)
        lock.BackgroundColor3 = record.IsLocked and Color3.fromRGB(180, 120, 0) or MIST
        lock.BorderSizePixel = 0
        lock.AutoButtonColor = false
        lock.Font = Enum.Font.GothamBold
        lock.TextSize = 12
        lock.TextColor3 = WHITE
        lock.Text = record.IsLocked and "🔒" or "🔓"
        lock.ZIndex = 4
        lock.Parent = row
        round(lock)

        local delete = Instance.new("TextButton")
        delete.AnchorPoint = Vector2.new(1, 0.5)
        delete.Position = UDim2.new(1, -12, 0.5, 0)
        delete.Size = UDim2.fromOffset(28, 28)
        delete.BackgroundColor3 = record.IsLocked and SURFACE_3 or Color3.fromRGB(180, 40, 60)
        delete.BorderSizePixel = 0
        delete.AutoButtonColor = false
        delete.Font = Enum.Font.GothamBold
        delete.TextSize = 14
        delete.TextColor3 = WHITE
        delete.Text = "×"
        delete.ZIndex = 4
        delete.Parent = row
        round(delete)

        hit.MouseButton1Click:Connect(function()
            ripple(row, PURPLE)
            openPreview(record)
        end)

        lock.MouseButton1Click:Connect(function()
            f15(record.FileName)
            refreshLoad()
        end)

        delete.MouseButton1Click:Connect(function()
            if record.IsLocked then
                delete.Text = "🔒"
                task.delay(0.8, function()
                    if delete.Parent then delete.Text = "×" end
                end)
            else
                f13(record.FileName)
                refreshLoad()
            end
        end)
    end
end

do
    local baseActivate = activate
    activate = function(name)
        baseActivate(name)
        if name == "Load" then refreshLoad() end
    end
end

local function pageHeader(page, titleText, infoText, readyText)
    UI.section(page, titleText)
    UI.note(page, infoText)
    return UI.status(page, readyText)
end

local function scanButtons(page, setter, list, category)
    for _, info in ipairs(list) do
        UI.button(page, {
            name = info.name,
            desc = info.desc,
            callback = function()
                setter("⏳ Đang quét " .. info.name .. "...")
                task.spawn(function()
                    local ok, data = pcall(info.fn)
                    if not ok or type(data) ~= "table" then
                        setter("❌ Lỗi khi quét " .. info.name)
                        return
                    end
                    if #data == 0 then
                        setter("❌ Không tìm thấy " .. info.name)
                        return
                    end
                    setter("✅ Tìm thấy " .. #data .. " " .. info.name)
                    f25(info.label, category, function() return data end)
                end)
            end,
        })
    end
end

-- ================== TAB: COPY ==================
do
    UI.section(CopyPage, "copy nhanh")
    UI.button(CopyPage, {
        name = "🌟 COPY TẤT CẢ",
        desc = "Tools + Gui + Nametag + RS + Lighting + Map",
        callback = function()
            f25("ALL_Data", "All", function() return copyAllData() end)
        end,
    })
    UI.button(CopyPage, {
        name = "🗡️ 1. Copy All Tools",
        callback = function()
  f25("Tools_Data", "Tools", function()
    local v75, v76 = {}, {}
    f16(workspace, "Tool", v75, v76)
    for _, plr in ipairs(players:GetPlayers()) do
      if plr.Character then f16(plr.Character, "Tool", v75, v76) end
      if plr:FindFirstChild("Backpack") then f16(plr.Backpack, "Tool", v75, v76) end
    end
    f16(starterPack, "Tool", v75, v76)
    return v75
  end)
        end,
    })
    UI.button(CopyPage, {
        name = "🖼️ 2. Copy StarterGui",
        callback = function()
  f25("Gui_Data", "Gui", function()
    local v77 = {}
    for _, value27 in ipairs((localPlayer:FindFirstChild("PlayerGui") or starterGui):GetChildren()) do
      if value27.Name ~= "HuyPham_UI" then
        local v78 = f7(value27)
        if v78 then table.insert(v77, v78) end
      end
    end
    return v77
  end)
        end,
    })
    UI.button(CopyPage, {
        name = "🏷️ 3. Copy Nametag / SurfaceGui",
        callback = function()
  f25("Nametag_Data", "Nametag", function()
    local v79, v80 = {}, {}
    f18(workspace, { "BillboardGui", "SurfaceGui" }, v79, v80)
    for _, plr in ipairs(players:GetPlayers()) do
      if plr.Character then f18(plr.Character, { "BillboardGui", "SurfaceGui" }, v79, v80) end
    end
    return v79
  end)
        end,
    })
    UI.button(CopyPage, {
        name = "📦 4. Copy ReplicatedStorage",
        callback = function()
  f25("Replicated_Data", "ReplicatedStorage", function()
    local v81 = {}
    for _, value29 in ipairs(replicatedStorage:GetChildren()) do
      local v82 = f7(value29)
      if v82 then table.insert(v81, v82) end
    end
    return v81
  end)
        end,
    })
    UI.button(CopyPage, {
        name = "💡 5. Copy Lighting & Sky Map",
        callback = function()
  f25("Lighting_Data", "Lighting", function()
    local v83 = {}
    local v84 = f7(lighting)
    if v84 then table.insert(v83, v84) end
    return v83
  end)
        end,
    })
    UI.button(CopyPage, {
        name = "🗺️ 6. Copy Work / Map",
        callback = function()
  f25("Map_Work_Data", "Map", function()
    local v85 = {}
    for _, value30 in ipairs(workspace:GetChildren()) do
      if not value30:IsA("Terrain") and not value30:IsA("Camera")
        and not players:GetPlayerFromCharacter(value30) then
        local v86 = f7(value30)
        if v86 then table.insert(v85, v86) end
      end
    end
    return v85
  end)
        end,
    })
end

-- ================== TAB: LOAD ==================
do
    UI.section(LoadPage, "MỤC ĐÃ LƯU")
    local _, row = UI.note(LoadPage, "Bạn Chưa Có Mục Coppy Nào Cả", DIM)
    emptyRow = row

    local reset = UI.button(LoadPage, {
        name = "🔴 RESET DATA (Giữ Mục Đã Khoá)",
        desc = "xoá mọi mục chưa khoá",
        callback = function()
            f19()
            refreshLoad()
        end,
    })
    reset.LayoutOrder = 1000000
end

-- ================== TAB: SETTING ==================
do
    UI.section(SettingPage, "GIAO DIỆN")

    UI.toggle(SettingPage, {
        name = "📐 Bật Kéo Chỉnh Size GUI",
        desc = "hiện tay nắm ở góc dưới bên phải",
        value = true,
        callback = function(on)
            UIState.gripOn = on
            Grip.Visible = on and not UIState.minimized
        end,
    })

    UI.button(SettingPage, {
        name = "💾 Lưu Kích Thước GUI Này",
        desc = "lần sau mở lại giữ nguyên size",
        callback = function()
            local w, h = math.floor(UIState.width), math.floor(UIState.height)
            v6.SkyroW, v6.SkyroH = w, h
            v6.CustomSizeX, v6.CustomSizeY = w, h
            f3(v6)
            Toast.show("đã lưu", w .. " × " .. h, "✓")
        end,
    })

    UI.toggle(SettingPage, {
        name = "fluid motion",
        desc = "nền chuyển động, glow, shimmer",
        value = Fx.enabled,
        callback = function(on)
            Fx.enabled = on
            v6.Fx = on
            f3(v6)
        end,
    })

    UI.section(SettingPage, "🎨 MÀU GIAO DIỆN")

    local function applyTheme(color)
        local base = Fx.baseGradient
        if not base then return end
        if not color then
            base.Color = Fx.baseDefault
            return
        end
        base.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color:Lerp(WHITE, 0.12)),
            ColorSequenceKeypoint.new(0.55, color),
            ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(0, 0, 0), 0.35)),
        })
    end

    local themes = {
        { name = "Mặc định",   value = nil,                         swatch = Color3.fromRGB(42, 38, 58) },
        { name = "Trắng",      value = Color3.fromRGB(220, 220, 230), swatch = Color3.fromRGB(220, 220, 230) },
        { name = "Xanh Dương", value = Color3.fromRGB(15, 35, 65),    swatch = Color3.fromRGB(15, 35, 65) },
        { name = "Đỏ",         value = Color3.fromRGB(65, 15, 20),    swatch = Color3.fromRGB(65, 15, 20) },
        { name = "Tím",        value = Color3.fromRGB(45, 15, 65),    swatch = Color3.fromRGB(45, 15, 65) },
        { name = "Vàng",       value = Color3.fromRGB(80, 70, 15),    swatch = Color3.fromRGB(80, 70, 15) },
        { name = "Xanh Lục",   value = Color3.fromRGB(15, 65, 30),    swatch = Color3.fromRGB(15, 65, 30) },
        { name = "Hồng",       value = Color3.fromRGB(75, 20, 55),    swatch = Color3.fromRGB(75, 20, 55) },
        { name = "Cam",        value = Color3.fromRGB(80, 45, 15),    swatch = Color3.fromRGB(80, 45, 15) },
    }

    local picker = UI.dropdown(SettingPage, {
        name = "Danh Sách Chọn Màu",
        options = themes,
        callback = function(themeName, color)
            applyTheme(color)
            v6.Theme = themeName
            f3(v6)
        end,
    })

    for _, theme in ipairs(themes) do
        if theme.name == v6.Theme then
            picker:Set(theme.name)
            applyTheme(theme.value)
            break
        end
    end

    UI.label(SettingPage, "RightShift shows / hides the window", true)
end

-- ================== TAB: ADMIN ==================
do
    UI.section(AdminPage, "ĐỘI NGŨ")
    UI.roster(AdminPage, "👑 Huy Pham", { "Huy Pham" })
    UI.roster(AdminPage, "🛡️ ADMIN", { "Huy Pham" })
    UI.roster(AdminPage, "🔰 MODERATOR (MOD)", { "Huy Pham", "ManhVo" })
end

-- ================== TAB: LEAK ==================
do
    local setLeakStatus = pageHeader(LeakPage, "💻 HUY PHAM LEAK",
        "🔍 Logic tự kiểm tra môi trường:\n• Mobile: chỉ Model (không script)\n• PC executor: leak được cả script\n• Nếu thiếu công cụ → báo rõ, GUI vẫn chạy\n• File tự lưu vào Downloads\n\n⚠️ Mobile executor thường không có saveinstance",
        "Sẵn sàng. Bấm nút bên dưới.")

    UI.button(LeakPage, {
        name = "🗺️ LEAK MODEL",
        desc = "Chỉ Model — chạy được mọi executor",
        callback = function()
  setLeakStatus("🗺️ Đang leak MODEL... vui lòng đợi")
  task.spawn(function()
    local ok, res = safeLeak("model")
    if ok then
      setLeakStatus("✔ Xong MODEL!\n📁 " .. tostring(res))
    else
      setLeakStatus("❌ " .. tostring(res) .. "\n\n💡 GUI vẫn hoạt động.")
    end
  end)
        end,
    })

    UI.button(LeakPage, {
        name = "📦 LEAK FULL",
        desc = "⚠️ Cần PC executor — mobile sẽ báo lỗi",
        callback = function()
  setLeakStatus("📦 Đang thử leak FULL...")
  task.spawn(function()
    local ok, res = safeLeak("full")
    if ok then
      setLeakStatus("✔ Xong FULL!\n📁 " .. tostring(res))
    else
      setLeakStatus("❌ " .. tostring(res) .. "\n\n💡 GUI vẫn hoạt động.")
    end
  end)
        end,
    })

end

-- ================== TAB: VFX ==================
do
    local setVFXStatus = pageHeader(VFXPage, "✨ HUY PHAM VFX LEAK",
        "🎯 Leak toàn bộ hiệu ứng hình ảnh:\n• Particle / Beam / Trail / Fire / Smoke / Sparkles\n• Explosion / Light / Sound / Animation\n• BillboardGui / Decal / Texture / Mesh\n\n✅ Hoạt động cả MOBILE lẫn PC",
        "Sẵn sàng leak VFX. Bấm nút bên dưới.")

    UI.button(VFXPage, {
        name = "✨ LEAK TẤT CẢ VFX",
        desc = "Quét toàn bộ VFX — mobile & PC đều chạy được",
        callback = function()
  setVFXStatus("✨ Đang quét TẤT CẢ VFX + Model chứa VFX...")
  task.spawn(function()
    local vfxOnly = copyVFX()
    local modelsWithVFX = copyVFXWithModels()
    local finalResult = {}
    local seenNames = {}
    for _, item in ipairs(modelsWithVFX) do
      local key = (item.Cls or "") .. "_" .. (item.Name or "")
      if not seenNames[key] then seenNames[key] = true; table.insert(finalResult, item) end
    end
    for _, item in ipairs(vfxOnly) do
      local key = (item.Cls or "") .. "_" .. (item.Name or "")
      if not seenNames[key] then seenNames[key] = true; table.insert(finalResult, item) end
    end
    if #finalResult == 0 then
      setVFXStatus("❌ Không tìm thấy VFX nào trong game")
      return
    end
    setVFXStatus("✅ Tìm thấy:\n• " .. #vfxOnly .. " VFX rời\n• " .. #modelsWithVFX .. " Model chứa VFX\n• Tổng: " .. #finalResult .. " instance")
    f25("VFX_Full", "VFX", function() return finalResult end)
  end)
        end,
    })

    UI.button(VFXPage, {
        name = "👤 Chỉ VFX của Player (character)",
        callback = function()
  setVFXStatus("👤 Đang quét VFX của Player...")
  task.spawn(function()
    local allVFX = {}
    for _, plr in ipairs(players:GetPlayers()) do
      if plr.Character then
        pcall(function()
          for _, d in ipairs(plr.Character:GetDescendants()) do
            if isVFXInstance(d) then
              local s = f7(d)
              if s then table.insert(allVFX, s) end
            end
          end
        end)
      end
    end
    if #allVFX == 0 then setVFXStatus("❌ Không có VFX nào trên Player"); return end
    setVFXStatus("✅ Tìm thấy " .. #allVFX .. " VFX từ Player")
    f25("VFX_Player", "VFX", function() return allVFX end)
  end)
        end,
    })

    UI.button(VFXPage, {
        name = "🌍 Chỉ VFX của Map (workspace)",
        callback = function()
  setVFXStatus("🌍 Đang quét VFX của Map...")
  task.spawn(function()
    local allVFX = {}
    pcall(function()
      for _, d in ipairs(workspace:GetDescendants()) do
        if isVFXInstance(d) then
          local s = f7(d)
          if s then table.insert(allVFX, s) end
        end
      end
    end)
    if #allVFX == 0 then setVFXStatus("❌ Không có VFX nào trong workspace"); return end
    setVFXStatus("✅ Tìm thấy " .. #allVFX .. " VFX trong Map")
    f25("VFX_Map", "VFX", function() return allVFX end)
  end)
        end,
    })

    UI.button(VFXPage, {
        name = "🖼️ Chỉ VFX trong GUI (StarterGui/PlayerGui)",
        callback = function()
  setVFXStatus("🖼️ Đang quét VFX trong GUI...")
  task.spawn(function()
    local allVFX = {}
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
      pcall(function()
        for _, d in ipairs(pg:GetDescendants()) do
          if isVFXInstance(d) then
            local s = f7(d)
            if s then table.insert(allVFX, s) end
          end
        end
      end)
    end
    pcall(function()
      for _, d in ipairs(starterGui:GetDescendants()) do
        if isVFXInstance(d) then
          local s = f7(d)
          if s then table.insert(allVFX, s) end
        end
      end
    end)
    if #allVFX == 0 then setVFXStatus("❌ Không có VFX nào trong GUI"); return end
    setVFXStatus("✅ Tìm thấy " .. #allVFX .. " VFX trong GUI")
    f25("VFX_Gui", "VFX", function() return allVFX end)
  end)
        end,
    })

    UI.button(VFXPage, {
        name = "📦 LEAK MODEL CHỨA VFX (kiếm, súng, pet...)",
        callback = function()
  setVFXStatus("📦 Đang quét Model chứa VFX...")
  task.spawn(function()
    local models = copyVFXWithModels()
    if #models == 0 then setVFXStatus("❌ Không tìm thấy Model nào chứa VFX"); return end
    setVFXStatus("✅ Tìm thấy " .. #models .. " Model có VFX")
    f25("VFX_With_Models", "VFX", function() return models end)
  end)
        end,
    })

    UI.button(VFXPage, {
        name = "🎯 Chỉ Model có VFX (không lấy VFX rời)",
        callback = function()
  setVFXStatus("🎯 Đang quét Model có VFX...")
  task.spawn(function()
    local models = copyVFXModelsOnly()
    if #models == 0 then setVFXStatus("❌ Không tìm thấy Model có VFX"); return end
    setVFXStatus("✅ Tìm thấy " .. #models .. " Model có VFX")
    f25("VFX_Models_Only", "VFX", function() return models end)
  end)
        end,
    })

    UI.button(VFXPage, {
        name = "👤 Model VFX của Player (áo giáp, cánh...)",
        callback = function()
  setVFXStatus("👤 Đang quét Model VFX của Player...")
  task.spawn(function()
    local result = {}
    local visited = {}
    local modelsAdded = {}
    for _, plr in ipairs(players:GetPlayers()) do
      if plr.Character then
        pcall(function()
          for _, d in ipairs(plr.Character:GetDescendants()) do
            if not visited[d] and isVFXInstance(d) then
              visited[d] = true
              local parentModel = findParentModel(d)
              if parentModel and not modelsAdded[parentModel] then
                modelsAdded[parentModel] = true
                local s = f7(parentModel)
                if s then table.insert(result, s) end
              end
            end
          end
        end)
      end
    end
    if #result == 0 then setVFXStatus("❌ Không có Model VFX nào trên Player"); return end
    setVFXStatus("✅ Tìm thấy " .. #result .. " Model VFX từ Player")
    f25("VFX_Player_Models", "VFX", function() return result end)
  end)
        end,
    })

    UI.button(VFXPage, {
        name = "🌈 LEAK EFFECT (Bloom / Blur / ColorCorrection...)" ,
        desc = "Quét PostEffect và hiệu ứng môi trường trong Lighting, Map và GUI",
        callback = function()
            setVFXStatus("🌈 Đang quét Effect...")
            task.spawn(function()
                local effects = {}
                local visited = {}
                local effectClasses = { "PostEffect", "Atmosphere", "Sky", "Clouds" }
                local roots = { workspace, replicatedStorage, lighting, starterGui }
                local pg = localPlayer:FindFirstChild("PlayerGui")
                if pg then table.insert(roots, pg) end
                for _, root in ipairs(roots) do
                    pcall(function()
                        for _, d in ipairs(root:GetDescendants()) do
                            if not visited[d] then
                                local matched = false
                                for _, className in ipairs(effectClasses) do
                                    if d:IsA(className) then matched = true; break end
                                end
                                if matched then
                                    visited[d] = true
                                    local item = f7(d)
                                    if item then table.insert(effects, item) end
                                end
                            end
                        end
                    end)
                end
                -- Lighting itself is a root and its direct children are included by GetDescendants.
                if #effects == 0 then
                    setVFXStatus("❌ Không tìm thấy Effect trong dữ liệu client đã tải")
                    return
                end
                setVFXStatus("✅ Tìm thấy " .. #effects .. " Effect. Đang lưu...")
                f25("Effect_Leak", "VFX", function() return effects end)
            end)
        end,
    })

end

-- ================== TAB: MEDIA ==================
do
    local setMediaStatus = pageHeader(MediaPage, "🎬 HUY PHAM MEDIA LEAK",
        "🎯 Leak media assets:\n• Animation (kỹ năng, vũ khí, biểu cảm)\n• Sound ID (nhạc, hiệu ứng âm thanh)\n• Mesh / Texture ID (model, hình ảnh)\n\n✅ Mobile & PC đều chạy được",
        "Sẵn sàng quét media.")

    UI.button(MediaPage, {
        name = "🎬 LEAK ANIMATION (kỹ năng, vũ khí...)",
        callback = function()
  setMediaStatus("🎬 Đang quét Animation...")
  task.spawn(function()
    local data = copyAnimations()
    if #data == 0 then setMediaStatus("❌ Không tìm thấy Animation"); return end
    setMediaStatus("✅ Tìm thấy " .. #data .. " Animation")
    f25("Animation_Data", "Media", function() return data end)
  end)
        end,
    })

    UI.button(MediaPage, {
        name = "🔊 LEAK SOUND ID (nhạc, hiệu ứng)",
        callback = function()
  setMediaStatus("🔊 Đang quét Sound ID...")
  task.spawn(function()
    local data = copySoundIDs()
    if #data == 0 then setMediaStatus("❌ Không tìm thấy Sound"); return end
    setMediaStatus("✅ Tìm thấy " .. #data .. " Sound ID")
    f25("Sound_IDs", "Media", function() return data end)
  end)
        end,
    })

    UI.button(MediaPage, {
        name = "🧊 LEAK MESH / TEXTURE ID (model, ảnh)",
        callback = function()
  setMediaStatus("🧊 Đang quét Mesh/Texture ID...")
  task.spawn(function()
    local data = copyMeshTextureIDs()
    if #data == 0 then setMediaStatus("❌ Không tìm thấy Mesh/Texture"); return end
    setMediaStatus("✅ Tìm thấy " .. #data .. " Mesh/Texture ID")
    f25("Mesh_IDs", "Media", function() return data end)
  end)
        end,
    })

    UI.button(MediaPage, {
        name = "✨ LEAK TẤT CẢ MEDIA (Anim + Sound + Mesh)",
        callback = function()
  setMediaStatus("✨ Đang quét tất cả Media...")
  task.spawn(function()
    local anims = copyAnimations()
    local sounds = copySoundIDs()
    local meshes = copyMeshTextureIDs()
    local result = {}
    for _, v in ipairs(anims) do table.insert(result, v) end
    for _, v in ipairs(sounds) do table.insert(result, v) end
    for _, v in ipairs(meshes) do table.insert(result, v) end
    if #result == 0 then setMediaStatus("❌ Không tìm thấy media nào"); return end
    setMediaStatus("✅ Tìm thấy:\n• " .. #anims .. " Animation\n• " .. #sounds .. " Sound\n• " .. #meshes .. " Mesh/Texture\n• Tổng: " .. #result)
    f25("Media_All", "Media", function() return result end)
  end)
        end,
    })

end

-- ================== TAB: REMOTE ==================
do
    local setRemoteStatus = pageHeader(RemotePage, "🔗 HUY PHAM REMOTE & INFO",
        "🎯 Leak remote + thông tin:\n• RemoteEvent / RemoteFunction\n• Player Info (tên, UserId, WalkSpeed...)\n• Part Position / CFrame\n• Attribute / Tag / Description",
        "Sẵn sàng.")

    UI.button(RemotePage, {
        name = "🔗 LEAK REMOTE (RemoteEvent/Function)",
        callback = function()
  setRemoteStatus("🔗 Đang quét Remote...")
  task.spawn(function()
    local data = copyRemotes()
    if #data == 0 then setRemoteStatus("❌ Không tìm thấy Remote"); return end
    setRemoteStatus("✅ Tìm thấy " .. #data .. " Remote")
    f25("Remotes_Data", "Remote", function() return data end)
  end)
        end,
    })

    UI.button(RemotePage, {
        name = "👥 LEAK PLAYER INFO (tên, UserId, Speed...)",
        callback = function()
  setRemoteStatus("👥 Đang quét Player Info...")
  task.spawn(function()
    local data = copyPlayerInfo()
    if #data == 0 then setRemoteStatus("❌ Không có player nào"); return end
    setRemoteStatus("✅ Tìm thấy " .. #data .. " player")
    f25("Player_Info", "Remote", function() return data end)
  end)
        end,
    })

    UI.button(RemotePage, {
        name = "📐 LEAK PART POSITION (vị trí tất cả Part)",
        callback = function()
  setRemoteStatus("📐 Đang quét Part Position...")
  task.spawn(function()
    local data = copyPartPositions()
    if #data == 0 then setRemoteStatus("❌ Không tìm thấy Part"); return end
    setRemoteStatus("✅ Tìm thấy " .. #data .. " Part")
    f25("Part_Positions", "Remote", function() return data end)
  end)
        end,
    })

    UI.button(RemotePage, {
        name = "🏷️ LEAK ATTRIBUTE / TAG",
        callback = function()
  setRemoteStatus("🏷️ Đang quét Attribute / Tag...")
  task.spawn(function()
    local data = copyAttributesTags()
    if #data == 0 then setRemoteStatus("❌ Không tìm thấy Attribute/Tag"); return end
    setRemoteStatus("✅ Tìm thấy " .. #data .. " instance có Attribute/Tag")
    f25("Attributes_Tags", "Remote", function() return data end)
  end)
        end,
    })

    UI.button(RemotePage, {
        name = "📝 LEAK HUMANOID DESC / TOOLTIP",
        callback = function()
  setRemoteStatus("📝 Đang quét Description / ToolTip...")
  task.spawn(function()
    local data = copyHumanoidDescription()
    if #data == 0 then setRemoteStatus("❌ Không tìm thấy description nào"); return end
    setRemoteStatus("✅ Tìm thấy " .. #data .. " description")
    f25("Descriptions", "Remote", function() return data end)
  end)
        end,
    })

    UI.button(RemotePage, {
        name = "📜 LEAK SCRIPT SOURCE (chỉ PC có decompile)",
        callback = function()
  setRemoteStatus("📜 Đang quét Script Source...")
  task.spawn(function()
    local data = copyScriptSource()
    if #data == 0 then setRemoteStatus("❌ Không tìm thấy script"); return end
    local hasDecompile = type(decompile) == "function" or type(getscriptbytecode) == "function"
    setRemoteStatus("✅ Tìm thấy " .. #data .. " script" .. (hasDecompile and "" or "\n⚠️ Executor không có decompile"))
    f25("Script_Source", "Remote", function() return data end)
  end)
        end,
    })

    UI.button(RemotePage, {
        name = "🛠️ LEAK TOOL ĐANG CẦM (mọi player)",
        callback = function()
  setRemoteStatus("🛠️ Đang quét Tool đang cầm...")
  task.spawn(function()
    local data = {}
    for _, plr in ipairs(players:GetPlayers()) do
      if plr.Character then
        pcall(function()
          for _, tool in ipairs(plr.Character:GetChildren()) do
            if tool:IsA("Tool") then
              local s = f7(tool)
              if s then table.insert(data, s) end
            end
          end
        end)
      end
    end
    if #data == 0 then setRemoteStatus("❌ Không có player nào đang cầm tool"); return end
    setRemoteStatus("✅ Tìm thấy " .. #data .. " tool đang cầm")
    f25("Tools_InHand", "Remote", function() return data end)
  end)
        end,
    })

    UI.button(RemotePage, {
        name = "👁️ LEAK GUI ĐANG HIỂN THỊ",
        callback = function()
  setRemoteStatus("👁️ Đang quét GUI đang hiển thị...")
  task.spawn(function()
    local data = {}
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
      pcall(function()
        for _, gui in ipairs(pg:GetChildren()) do
          if gui:IsA("ScreenGui") and gui.Enabled then
            local s = f7(gui)
            if s then table.insert(data, s) end
          end
        end
      end)
    end
    if #data == 0 then setRemoteStatus("❌ Không có GUI nào đang hiện"); return end
    setRemoteStatus("✅ Tìm thấy " .. #data .. " GUI đang hiển thị")
    f25("Gui_Visible", "Remote", function() return data end)
  end)
        end,
    })


    UI.section(RemotePage, "THÊM")
    local remoteExtras = {
        { name = "💾 VALUE OBJECT", desc = "Int / String / Bool / Object Value + leaderstats", fn = Leaks.valueObjects, label = "Value_Objects" },
        { name = "🧬 MODULE CONFIG (require)", desc = "chạy require từng module, dump bảng config", fn = Leaks.moduleConfig, label = "Module_Config" },
        { name = "💬 CHAT COMMAND / CHANNEL", desc = "lệnh chat đăng ký trong TextChatService", fn = Leaks.chatCommands, label = "Chat_Commands" },
    }
    scanButtons(RemotePage, setRemoteStatus, remoteExtras, "Remote")
end

-- ================== TAB: SPY ==================
do
    local setSpyStatus = pageHeader(SpyPage, "🕵️ SPY — Do thám server",
        "🎯 Do thám server:\n• Game Info (PlaceId, JobId, Creator)\n• Player Avatar / Backpack / Team\n• Leaderboard / Sound đang phát\n• Badge / Gamepass",
        "Sẵn sàng spy.")

    local spyButtons = {
  { name = "🎮 GAME INFO", color = Color3.fromRGB(200, 80, 60), fn = copyGameInfo, label = "GameInfo" },
  { name = "👤 PLAYER AVATAR", color = Color3.fromRGB(180, 100, 80), fn = copyPlayerAvatar, label = "Player_Avatar" },
  { name = "🎒 BACKPACK ITEM", color = Color3.fromRGB(150, 80, 100), fn = copyBackpack, label = "Backpack" },
  { name = "🏆 TEAM + LEADERBOARD", color = Color3.fromRGB(200, 130, 60), fn = copyTeamLeaderboard, label = "Team_Leaderboard" },
  { name = "🔊 SOUND ĐANG PHÁT", color = Color3.fromRGB(160, 60, 160), fn = copySoundPlaying, label = "Sound_Playing" },
  { name = "🏅 BADGE / GAMEPASS", color = Color3.fromRGB(180, 140, 60), fn = copyBadgesGamepasses, label = "Badge_Gamepass" },
    }

    scanButtons(SpyPage, setSpyStatus, spyButtons, "Spy")

    UI.section(SpyPage, "THÊM")
    local spyExtras = {
        { name = "⚙️ GAME SETTINGS", desc = "Workspace + StarterPlayer + Players + Lighting", fn = Leaks.gameSettings, label = "Game_Settings" },
        { name = "🎥 CAMERA", desc = "FOV, CameraType, CFrame...", fn = Leaks.cameraInfo, label = "Camera" },
        { name = "📊 SERVER STATS", desc = "ping, FPS, ram, số instance", fn = Leaks.serverStats, label = "Server_Stats" },
    }
    scanButtons(SpyPage, setSpyStatus, spyExtras, "Spy")
end

-- ================== TAB: DISCOVER ==================
do
    local setDiscoverStatus = pageHeader(DiscoverPage, "🔍 DISCOVER — Tìm bí mật",
        "🎯 Tìm bí mật trong game:\n• Hidden Parts (tường ẩn, vault)\n• ProximityPrompt / GUI Text ẩn\n• Config / Anti-cheat / DataStore\n• HTTP / Webhook (chỉ PC)",
        "Sẵn sàng discover.")

    local discoverButtons = {
  { name = "👻 HIDDEN PARTS (tường ẩn)", color = Color3.fromRGB(150, 150, 50), fn = copyHiddenParts, label = "Hidden_Parts" },
  { name = "💬 PROXIMITY PROMPT", color = Color3.fromRGB(180, 150, 50), fn = copyProximityPrompts, label = "Proximity_Prompts" },
  { name = "📝 GUI TEXT (lộ text ẩn)", color = Color3.fromRGB(200, 170, 50), fn = copyGuiText, label = "Gui_Text" },
  { name = "⚙️ GAME CONFIG", color = Color3.fromRGB(160, 120, 60), fn = copyGameConfig, label = "Game_Config" },
  { name = "🛡️ ANTI-CHEAT", color = Color3.fromRGB(180, 80, 60), fn = copyAntiCheat, label = "AntiCheat" },
  { name = "🗄️ DATASTORE KEY (PC)", color = Color3.fromRGB(120, 80, 180), fn = copyDataStoreKeys, label = "DataStore_Keys" },
  { name = "🌐 HTTP / WEBHOOK (PC)", color = Color3.fromRGB(80, 140, 200), fn = copyHttpWebhooks, label = "HTTP_Webhooks" },
    }

    scanButtons(DiscoverPage, setDiscoverStatus, discoverButtons, "Discover")

    UI.section(DiscoverPage, "THÊM")
    local discoverExtras = {
        { name = "🌳 EXPLORER TREE (3 tầng)", desc = "cây thư mục các service chính", fn = Leaks.explorerTree, label = "Explorer_Tree" },
    }
    scanButtons(DiscoverPage, setDiscoverStatus, discoverExtras, "Discover")
end

-- ================== TAB: CLONE ==================
do
    local setCloneStatus = pageHeader(ClonePage, "🎭 CLONE — Copy model",
        "🎯 Clone model:\n• Full Character (toàn bộ nhân vật)\n• NPC / Quái / Boss\n• Vehicle / Seat\n• Model Bounding Box (kích thước)\n• Lighting Preset (đồ họa)",
        "Sẵn sàng clone.")

    local cloneButtons = {
  { name = "👤 FULL CHARACTER (nhân vật)", color = Color3.fromRGB(60, 180, 120), fn = copyFullCharacter, label = "Full_Character" },
  { name = "🤖 NPC / QUÁI / BOSS", color = Color3.fromRGB(120, 180, 100), fn = copyNPCs, label = "NPCs" },
  { name = "🚗 VEHICLE / SEAT", color = Color3.fromRGB(150, 150, 80), fn = copyVehicles, label = "Vehicles" },
  { name = "📦 MODEL BOUNDING BOX", color = Color3.fromRGB(80, 150, 200), fn = copyModelBoundingBox, label = "Model_BoundingBox" },
  { name = "💡 LIGHTING PRESET (đồ họa)", color = Color3.fromRGB(200, 180, 80), fn = copyLightingPreset, label = "Lighting_Preset" },
    }

    scanButtons(ClonePage, setCloneStatus, cloneButtons, "Clone")
end

-- ================== TAB: SCRIPT ==================
do
    local setScriptStatus = pageHeader(ScriptPage, "📜 SCRIPT LEAK",
        "🎯 Leak script theo từng nơi:\n• LocalScript / ModuleScript / StarterPlayerScripts\n• ReplicatedFirst + script nằm trong Tool\n• Danh sách đường dẫn (không cần decompile)\n\n⚠️ Cần decompile để lấy source — không có thì chỉ lấy cấu trúc",
        "Sẵn sàng leak script.")

    local scriptButtons = {
        { name = "📜 TẤT CẢ SCRIPT", desc = "LocalScript + ModuleScript + Script (cần decompile)", fn = copyScriptSource, label = "Script_All" },
        { name = "🧩 LOCAL SCRIPT", desc = "chỉ LocalScript chạy trên client", fn = Leaks.localScripts, label = "LocalScripts" },
        { name = "📦 MODULE SCRIPT", desc = "ModuleScript ở mọi nơi client thấy", fn = Leaks.moduleScripts, label = "ModuleScripts" },
        { name = "🚀 STARTER / PLAYER SCRIPTS", desc = "StarterPlayerScripts, CharacterScripts, PlayerScripts", fn = Leaks.starterScripts, label = "Starter_Scripts" },
        { name = "⚡ REPLICATED FIRST", desc = "script chạy đầu game (loading screen...)", fn = Leaks.replicatedFirst, label = "ReplicatedFirst" },
        { name = "🛠️ SCRIPT TRONG TOOL", desc = "tool có script bên trong", fn = Leaks.toolScripts, label = "Tool_Scripts" },
        { name = "🗂️ DANH SÁCH SCRIPT", desc = "tên + đường dẫn, không cần decompile", fn = Leaks.scriptList, label = "Script_List" },
    }

    scanButtons(ScriptPage, setScriptStatus, scriptButtons, "Script")
end

-- ================== TAB: MAP ==================
do
    local setMapStatus = pageHeader(MapPage, "🗺️ MAP LEAK",
        "🎯 Leak chi tiết của map:\n• Terrain / Spawn / Touch part / ClickDetector\n• Danh sách model + kích thước\n• SurfaceAppearance / MaterialVariant (texture ID)\n\n✅ Mobile & PC đều chạy được",
        "Sẵn sàng quét map.")

    local mapButtons = {
        { name = "⛰️ TERRAIN", desc = "nước, màu từng loại terrain, decoration", fn = Leaks.terrain, label = "Terrain" },
        { name = "🏁 SPAWN LOCATION", desc = "điểm hồi sinh + team", fn = Leaks.spawns, label = "Spawns" },
        { name = "💥 TOUCH PARTS", desc = "part có Touched (kill brick, teleport, coin...)", fn = Leaks.touchParts, label = "Touch_Parts" },
        { name = "👆 CLICK DETECTOR", desc = "vị trí + tầm bấm", fn = Leaks.clickDetectors, label = "Click_Detectors" },
        { name = "🏘️ DANH SÁCH MODEL", desc = "model / folder trong workspace + kích thước", fn = Leaks.modelList, label = "Model_List" },
        { name = "🎨 SURFACE APPEARANCE", desc = "ColorMap / Normal / Metalness / Roughness", fn = Leaks.surfaceAppearances, label = "SurfaceAppearance" },
        { name = "🧱 MATERIAL VARIANT", desc = "texture vật liệu custom của map", fn = Leaks.materialVariants, label = "MaterialVariants" },
    }

    scanButtons(MapPage, setMapStatus, mapButtons, "Map")
end

-- ================== TAB: GUI ==================
do
    local setGuiStatus = pageHeader(GuiPage, "🖼️ GUI LEAK",
        "🎯 Leak giao diện game:\n• Nút bấm, image ID, SpriteSheet\n• ScreenGui / Frame đang ẩn\n• Font + bảng màu đang dùng\n\n💡 Copy nguyên StarterGui ở tab Copy",
        "Sẵn sàng quét GUI.")

    local guiButtons = {
        { name = "🔘 TẤT CẢ NÚT BẤM", desc = "TextButton + ImageButton, text và ảnh", fn = Leaks.guiButtons, label = "Gui_Buttons" },
        { name = "🖼️ IMAGE ID (icon, ảnh GUI)", desc = "kèm ImageRect của spritesheet", fn = Leaks.imageIds, label = "Gui_ImageIds" },
        { name = "🙈 SCREENGUI ĐANG TẮT", desc = "menu ẩn, GUI chưa mở", fn = Leaks.hiddenScreenGuis, label = "Hidden_ScreenGuis" },
        { name = "👻 FRAME ĐANG ẨN", desc = "frame Visible = false (shop, popup...)", fn = Leaks.hiddenFrames, label = "Hidden_Frames" },
        { name = "🔤 FONT ĐÃ DÙNG", desc = "thống kê font trong GUI", fn = Leaks.fontsUsed, label = "Gui_Fonts" },
        { name = "🎨 BẢNG MÀU GUI", desc = "40 màu nền hay dùng nhất", fn = Leaks.colorPalette, label = "Gui_Palette" },
    }

    scanButtons(GuiPage, setGuiStatus, guiButtons, "Gui")
end

-- ================== TAB: AVATAR ==================
do
    local setAvatarStatus = pageHeader(AvatarPage, "🧍 AVATAR LEAK",
        "🎯 Leak nhân vật của mọi player trong server:\n• Accessory / Clothing / Body Colors\n• Animation đang chạy (AnimationId)\n• Rig Motor6D (C0 / C1)",
        "Sẵn sàng quét avatar.")

    local avatarButtons = {
        { name = "🎩 ACCESSORY (mọi player)", desc = "phụ kiện + mesh/texture", fn = Leaks.accessories, label = "Accessories" },
        { name = "👕 CLOTHING ID", desc = "áo, quần, graphic", fn = Leaks.clothing, label = "Clothing" },
        { name = "🎨 BODY COLORS", desc = "màu 6 bộ phận cơ thể", fn = Leaks.bodyColors, label = "Body_Colors" },
        { name = "💃 ANIMATION ĐANG CHẠY", desc = "AnimationId của mọi player lúc này", fn = Leaks.playingAnims, label = "Playing_Anims" },
        { name = "🦴 RIG / MOTOR6D", desc = "C0 / C1 các khớp nhân vật", fn = Leaks.rigJoints, label = "Rig_Joints" },
    }

    scanButtons(AvatarPage, setAvatarStatus, avatarButtons, "Avatar")
end

-- ================== KHỞI TẠO ==================
activate("Copy")
setStatus("up", "ready")
showWindow(true)

local Controller = {
    destroy = function()
        for _, connection in ipairs(Fx.connections) do
            pcall(function() connection:Disconnect() end)
        end
        Fx.connections = {}
        Fx.animators = {}
        pcall(function() Gui:Destroy() end)
        _G.HuyPhamHub = nil
    end,
}
_G.HuyPhamHub = Controller

print("✅ HUY PHAM HUB đã load!")
print("   📱 Mobile + 💻 PC đều chạy được")
print("   📋 11 tab: COPY / LOAD / SETTING / ADMIN / LEAK PC / VFX / MEDIA / REMOTE / SPY / DISCOVER / CLONE")
print("   ⌨️ RightShift: ẩn / hiện menu")

end

buildHub()
