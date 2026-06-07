-- =============================================
--           IKGHUB v2 - Versión Mejorada
-- =============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "IKGHUB v2 | Arena de Francotiradores",
    LoadingTitle = "IKGHUB v2",
    LoadingSubtitle = "by ɪᴋɢᴍᴏɴxʀ",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local Aiming = false
local aimbotConnection = nil
local activeESP = {}
local TeamCheck = false
local TriggerDistance = 120

local function Notify(title, content)
    Rayfield:Notify({Title = title, Content = content, Duration = 2})
end

-- ==================== FUNCIONES ====================
local function IsReady(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if TeamCheck and Players:GetPlayerFromCharacter(char) and Players:GetPlayerFromCharacter(char).TeamColor == player.TeamColor then
        return false
    end
    return true, char, char.HumanoidRootPart
end

local function CreateESP(character)
    if not character then return end
    if character:FindFirstChild("IKGESP") then return end
    local part = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    if not part then return end
    local box = Instance.new("SelectionBox")
    box.Name = "IKGESP"
    box.Adornee = part
    box.LineThickness = 0.05
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Parent = part
    activeESP[character] = box
end

local function ClearESP()
    for _, v in pairs(activeESP) do v:Destroy() end
    activeESP = {}
end

-- ==================== AIMBOT LOOP ====================
local function StartAimbot()
    if aimbotConnection then return end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not Aiming then return end
        
        local closest = nil
        local shortestDist = TriggerDistance
        
        for _, other in ipairs(Players:GetPlayers()) do
            if other == player then continue end
            local ready, char, part = IsReady(other.Character)
            if ready then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mousePos = Vector2.new(player:GetMouse().X, player:GetMouse().Y)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = char
                    end
                end
            end
        end
        
        if closest then
            local _, _, part = IsReady(closest)
            if part then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                CreateESP(closest)
            end
        end
    end)
end

local function StopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- ==================== GUI ====================
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateSection("Aimbot")

CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        Aiming = Value
        if Value then
            StartAimbot()
            Notify("Aimbot", "✅ Activado - Apuntando automáticamente")
        else
            StopAimbot()
            Notify("Aimbot", "❌ Desactivado")
        end
    end,
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Callback = function(Value)
        TeamCheck = Value
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

CombatTab:CreateSection("ESP")

CombatTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            ESP_Enabled = true
            Notify("ESP", "✅ Activado")
            -- Crear ESP en jugadores existentes
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    CreateESP(plr.Character)
                end
            end
        else
            ESP_Enabled = false
            ClearESP()
            Notify("ESP", "❌ Desactivado")
        end
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
MenuTab:CreateLabel("Version: 1.12")
MenuTab:CreateLabel("Credits: ikgmonher")

Notify("IKGHUB v2", "Cargado correctamente - Aimbot Mejorado")

-- ==================== AIMBOT ikgmonher ====================
_G.AimbotEnabled = _G.AimbotEnabled == nil and true or _G.AimbotEnabled
_G.TeamCheck = _G.TeamCheck == nil and false or _G.TeamCheck
_G.AimPart = _G.AimPart or "Head"
_G.CircleRadius = _G.CircleRadius or 120
_G.CircleVisible = _G.CircleVisible == nil and true or _G.CircleVisible
_G.CircleColor = _G.CircleColor or Color3.fromRGB(0, 255, 0)

Notify("ikgmonher Aimbot", "Cargado - ikgmonher")

local ikg = {}
ikg.Camera = workspace.CurrentCamera
ikg.Players = game:GetService("Players")
ikg.RunService = game:GetService("RunService")
ikg.UserInput = game:GetService("UserInputService")
ikg.LocalPlayer = ikg.Players.LocalPlayer
ikg.Holding = false
ikg.AimSpeed = 0.35 -- smoothing factor (0-1)

local FOV = Drawing.new("Circle")
FOV.Visible = _G.CircleVisible
FOV.Radius = _G.CircleRadius
FOV.Color = _G.CircleColor
FOV.Thickness = 1
FOV.Transparency = 0.7

ikg.UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
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
    local c = p and p.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and c:FindFirstChild(_G.AimPart)
end

local function GetClosest()
    local mousePos = ikg.UserInput:GetMouseLocation()
    local closest = nil
    local shortest = _G.CircleRadius
    for _, pl in ipairs(ikg.Players:GetPlayers()) do
        if pl ~= ikg.LocalPlayer and IsAlive(pl) then
            if (not _G.TeamCheck) or (pl.Team ~= ikg.LocalPlayer.Team) then
                local part = pl.Character[_G.AimPart]
                if part then
                    local screenPos, onScreen = ikg.Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = part
                        end
                    end
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
        if target and target.Parent then
            local desired = CFrame.new(ikg.Camera.CFrame.Position, target.Position)
            ikg.Camera.CFrame = ikg.Camera.CFrame:Lerp(desired, math.clamp(ikg.AimSpeed, 0, 1))
            -- Create a simple highlight (non-persistent)
            if not target:FindFirstChild("IKG_AIM_HL") then
                local box = Instance.new("SelectionBox")
                box.Name = "IKG_AIM_HL"
                box.Adornee = target
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.LineThickness = 0.05
                box.Parent = target
                delay(0.15, function()
                    if box and box.Parent then box:Destroy() end
                end)
            end
        end
    end
end)

-- Cleanup on GUI destroy
local function CleanupIKG()
    if FOV then
        pcall(function() FOV:Remove() end)
    end
end

Window:OnClose(CleanupIKG)

-- ==================== SILENT AIM MODULE ====================
-- Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

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

-- try to require optional modules safely
local okEntity, EntityService = pcall(function() return require(ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("EntityService") and ReplicatedStorage.Remote.EntityService) end)
if not okEntity then
    okEntity = false
    EntityService = nil
end

local function GetEntityCharacter(Entity)
    if not Entity then return nil end
    local Inst = Entity.Instance
    if not Inst then
        return nil
    end
    if Inst:IsA("Player") then
        return Inst.Character
    end
    if Inst:IsA("Model") then
        return Inst
    end
    return nil
end

local function FindEntityPosition(EntityModel)
    if not EntityModel then return nil end
    local HRP = EntityModel:FindFirstChild("HumanoidRootPart")
    if HRP and HRP:IsA("BasePart") then
        return HRP.Position
    end
    local Head = EntityModel:FindFirstChild("Head")
    if Head and Head:IsA("BasePart") then
        return Head.Position
    end
    local Collider = EntityModel:FindFirstChild("Collider")
    if Collider then
        for _, Part in Collider:GetChildren() do
            if Part:IsA("BasePart") then
                return Part.Position
            end
        end
    end
    local Humanoid = EntityModel:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.RootPart then
        return Humanoid.RootPart.Position
    end
    return nil
end

local function FindTargetPart(EntityModel, WantHead)
    if not EntityModel then return nil, false end
    if WantHead then
        local Head = EntityModel:FindFirstChild("Head")
        if not Head then
            Head = EntityModel:FindFirstChild("Head", true)
        end
        if Head and Head:IsA("BasePart") then
            return Head, true
        end
    end

    local Collider = EntityModel:FindFirstChild("Collider")
    if Collider then
        local Parts = {}
        for _, Part in Collider:GetChildren() do
            if Part:IsA("BasePart") then
                table.insert(Parts, Part)
            end
        end
        if #Parts > 0 then
            return Parts[math.random(1, #Parts)], false
        end
    end

    local Shuffled = table.clone(NonHeadParts)
    for I = #Shuffled, 2, -1 do
        local J = math.random(1, I)
        Shuffled[I], Shuffled[J] = Shuffled[J], Shuffled[I]
    end
    for _, PartName in Shuffled do
        local Part = EntityModel:FindFirstChild(PartName)
        if not Part then
            Part = EntityModel:FindFirstChild(PartName, true)
        end
        if Part and Part:IsA("BasePart") then
            return Part, false
        end
    end

    local HRP = EntityModel:FindFirstChild("HumanoidRootPart")
    if HRP and HRP:IsA("BasePart") then
        return HRP, false
    end
    return nil, false
end

local function IsInFOV(WorldPosition)
    if not Camera then
        return false, math.huge
    end
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(WorldPosition)
    if not OnScreen then
        return false, math.huge
    end
    local MousePos = UserInputService:GetMouseLocation()
    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
    return Distance <= SA_Settings.FOVRadius, Distance
end

local function GetAllEnemyEntities()
    local Enemies = {}
    if okEntity and EntityService and type(EntityService.GetEntities) == "function" then
        for _, ent in ipairs(EntityService:GetEntities()) do
            local Character = GetEntityCharacter(ent)
            if Character and Character ~= LocalPlayer.Character then
                table.insert(Enemies, Character)
            end
        end
    else
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                table.insert(Enemies, pl.Character)
            end
        end
    end
    return Enemies
end

local currentTarget = nil

local function GetClosestEnemy()
    local Enemies = GetAllEnemyEntities()
    local ClosestModel = nil
    local ClosestDistance = math.huge
    for _, Model in ipairs(Enemies) do
        local Position = FindEntityPosition(Model)
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
            local part, isHead = FindTargetPart(model, wantHead)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    TargetDot.Visible = true
                    TargetDot.Position = Vector2.new(screenPos.X, screenPos.Y)
                else
                    TargetDot.Visible = false
                end
                currentTarget = {part = part, model = model, isHead = isHead}
            else
                TargetDot.Visible = false
                currentTarget = nil
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

local function GetSilentTarget()
    if not currentTarget then return nil end
    if math.random(1, 100) > SA_Settings.HitChance then return nil end
    if math.random(1, 100) <= SA_Settings.HeadChance then
        local head = currentTarget.model:FindFirstChild("Head") or currentTarget.model:FindFirstChild("Head", true)
        if head then
            return head, currentTarget.model
        end
    end
    return currentTarget.part, currentTarget.model
end

_G.GetSilentTarget = GetSilentTarget

-- GUI toggle
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = SA_Settings.SilentAimEnabled,
    Callback = function(Value)
        SA_Settings.SilentAimEnabled = Value
    end,
})
