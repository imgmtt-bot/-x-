-- =============================================
--           IKGHUB v2 - Versión Final Mejorada
-- =============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Ryshub | Arena de Franco",
    LoadingTitle = "Ryshub",
    LoadingSubtitle = "by ɪᴋɢᴍᴏɴxʀ",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local Aiming = false
local aimbotConnection = nil
local ESP_Enabled = false
local TriggerDistance = 120

local activeESP = {}
local espConnections = {}

local function Notify(title, content)
    Rayfield:Notify({Title = title, Content = content, Duration = 2})
end

-- ==================== ESP MEJORADO ====================
local function CreateESP(character)
    if not character or character:FindFirstChild("IKG_ESP_Highlight") then return end
    if character == player.Character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "IKG_ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    activeESP[character] = highlight
end

local function RemoveESP(character)
    if not character then return end
    local hl = character:FindFirstChild("IKG_ESP_Highlight")
    if hl then hl:Destroy() end
    activeESP[character] = nil
end

local function ClearAllESP()
    for char, _ in pairs(activeESP) do
        RemoveESP(char)
    end
    table.clear(activeESP)
end

local function EnableESP()
    if ESP_Enabled then return end
    ESP_Enabled = true
    ClearAllESP()

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character then
            CreateESP(pl.Character)
        end
    end

    espConnections.PlayerAdded = Players.PlayerAdded:Connect(function(pl)
        if pl == player then return end
        pl.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if ESP_Enabled then CreateESP(char) end
        end)
        if pl.Character then CreateESP(pl.Character) end
    end)

    espConnections.PlayerRemoving = Players.PlayerRemoving:Connect(function(pl)
        RemoveESP(pl.Character)
    end)

    Notify("ESP", "✅ Activado (Highlight Mejorado)")
end

local function DisableESP()
    ESP_Enabled = false
    ClearAllESP()

    for _, con in pairs(espConnections) do
        pcall(function() con:Disconnect() end)
    end
    table.clear(espConnections)

    Notify("ESP", "❌ Desactivado")
end

-- ==================== AIMBOT BÁSICO ====================
local function StartAimbot()
    if aimbotConnection then return end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not Aiming then return end

        local closest = nil
        local shortestDist = TriggerDistance
        local mousePos = Vector2.new(player:GetMouse().X, player:GetMouse().Y)

        for _, other in ipairs(Players:GetPlayers()) do
            if other == player then continue end
            local char = other.Character
            if not char then continue end
            local part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            if not part then continue end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = part
                    end
                end
            end
        end

        if closest then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        end
    end)
end

local function StopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- ==================== AIMBOT SUAVE (ikgmonher) ====================
_G.AimbotEnabled = true
_G.AimPart = "Head"
_G.CircleRadius = 120
_G.CircleVisible = true
_G.CircleColor = Color3.fromRGB(0, 255, 0)

local ikg = {
    Camera = workspace.CurrentCamera,
    Players = Players,
    RunService = RunService,
    UserInput = UserInputService,
    LocalPlayer = player,
    Holding = false,
    AimSpeed = 0.35
}

local FOV = Drawing.new("Circle")
FOV.Visible = _G.CircleVisible
FOV.Radius = _G.CircleRadius
FOV.Color = _G.CircleColor
FOV.Thickness = 1
FOV.Transparency = 0.7

ikg.UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        ikg.Holding = true
    end
end)

ikg.UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        ikg.Holding = false
    end
end)

local function IsAlive(p)
    local c = p.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and c:FindFirstChild(_G.AimPart)
end

local function GetClosest()
    local mousePos = ikg.UserInput:GetMouseLocation()
    local closest, shortest = nil, _G.CircleRadius

    for _, pl in ipairs(ikg.Players:GetPlayers()) do
        if pl ~= ikg.LocalPlayer and IsAlive(pl) then
            local part = pl.Character[_G.AimPart]
            local screenPos, onScreen = ikg.Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = part
                end
            end
        end
    end
    return closest
end

ikg.RunService.RenderStepped:Connect(function()
    local mousePos = ikg.UserInput:GetMouseLocation()
    FOV.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOV.Radius = _G.CircleRadius
    FOV.Visible = _G.CircleVisible

    if ikg.Holding and _G.AimbotEnabled then
        local target = GetClosest()
        if target then
            local desired = CFrame.new(ikg.Camera.CFrame.Position, target.Position)
            ikg.Camera.CFrame = ikg.Camera.CFrame:Lerp(desired, ikg.AimSpeed)
        end
    end
end)

-- ==================== SILENT AIM ====================
local SA_Settings = {
    SilentAimEnabled = true,
    HeadChance = 10,
    HitChance = 100,
    FOVRadius = 180,
}

local NonHeadParts = {"UpperTorso", "LowerTorso", "HumanoidRootPart", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg"}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 1
FOVCircle.Radius = SA_Settings.FOVRadius
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

local TargetDot = Drawing.new("Circle")
TargetDot.Visible = false
TargetDot.Thickness = 1
TargetDot.Radius = 4
TargetDot.Color = Color3.fromRGB(255, 0, 0)
TargetDot.Filled = true
TargetDot.Transparency = 1

local currentTarget = nil

local function IsInFOV(WorldPosition)
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(WorldPosition)
    if not OnScreen then return false, math.huge end
    local MousePos = UserInputService:GetMouseLocation()
    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
    return Distance <= SA_Settings.FOVRadius, Distance
end

local function GetAllEnemyEntities()
    local Enemies = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character then
            table.insert(Enemies, pl.Character)
        end
    end
    return Enemies
end

local function GetClosestEnemy()
    local Enemies = GetAllEnemyEntities()
    local ClosestModel, ClosestDistance = nil, math.huge

    for _, Model in ipairs(Enemies) do
        local HRP = Model:FindFirstChild("HumanoidRootPart")
        local Position = HRP and HRP.Position
        if Position then
            local InFOV, Distance = IsInFOV(Position)
            if InFOV and Distance < ClosestDistance then
                ClosestDistance = Distance
                ClosestModel = Model
            end
        end
    end
    return ClosestModel
end

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Radius = SA_Settings.FOVRadius
    FOVCircle.Visible = SA_Settings.SilentAimEnabled

    if SA_Settings.SilentAimEnabled then
        local model = GetClosestEnemy()
        if model then
            local wantHead = (math.random(1, 100) <= SA_Settings.HeadChance)
            local part = wantHead and model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
            if not part then part = model:FindFirstChildWhichIsA("BasePart") end

            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                TargetDot.Visible = onScreen
                if onScreen then
                    TargetDot.Position = Vector2.new(screenPos.X, screenPos.Y)
                end
                currentTarget = {part = part, model = model}
            end
        else
            TargetDot.Visible = false
            currentTarget = nil
        end
    else
        TargetDot.Visible = false
        currentTarget = nil
    end
end)

_G.GetSilentTarget = function()
    if not currentTarget or math.random(1, 100) > SA_Settings.HitChance then return nil end
    return currentTarget.part
end

-- ==================== GUI ====================
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({
    Name = "Aimbot (Click Izquierdo)",
    CurrentValue = false,
    Callback = function(Value)
        Aiming = Value
        if Value then StartAimbot() else StopAimbot() end
    end,
})

CombatTab:CreateToggle({
    Name = "Aimbot Suave (Click Derecho)",
    CurrentValue = true,
    Callback = function(Value)
        _G.AimbotEnabled = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Trigger Distance",
    Range = {50, 300},
    Increment = 10,
    CurrentValue = 120,
    Callback = function(Value)
        TriggerDistance = Value
    end,
})

CombatTab:CreateSection("ESP & Silent")
CombatTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(Value)
        if Value then EnableESP() else DisableESP() end
    end,
})

CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = SA_Settings.SilentAimEnabled,
    Callback = function(Value)
        SA_Settings.SilentAimEnabled = Value
    end,
})

-- ==================== VISUAL ====================
local VisualTab = Window:CreateTab("Visual", 6031097228)

VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        if v then
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 100000
        else
            game.Lighting.Brightness = 1
            game.Lighting.ClockTime = 12
        end
    end,
})

-- ==================== MENU ====================
local MenuTab = Window:CreateTab("Menu", 4483362458)
MenuTab:CreateLabel("Status: Enabled")
MenuTab:CreateLabel("Version: 2.0")
MenuTab:CreateLabel("Credits: ikgmonher + Grok")

Notify("IKGHUB v2", "Cargado Correctamente ✅")

-- Cleanup
Window:OnClose(function()
    DisableESP()
    StopAimbot()
    if FOV then FOV:Remove() end
    if FOVCircle then FOVCircle:Remove() end
    if TargetDot then TargetDot:Remove() end
end)
