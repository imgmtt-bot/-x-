-- =============================================
--           IKGHUB v2 - Aimbot al Más Cercano
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
local TriggerDistance = 150

local function Notify(title, content)
    Rayfield:Notify({Title = title, Content = content, Duration = 2})
end

-- ==================== FUNCIONES ====================
local function IsReady(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true, char, char.HumanoidRootPart
end

local function CreateESP(character)
    if character:FindFirstChild("IKGESP") then return end
    local box = Instance.new("SelectionBox")
    box.Name = "IKGESP"
    box.Adornee = character
    box.LineThickness = 0.05
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Parent = character
    activeESP[character] = box
end

local function ClearESP()
    for _, v in pairs(activeESP) do 
        if v and v.Parent then v:Destroy() end 
    end
    activeESP = {}
end

-- ==================== AIMBOT AL MÁS CERCANO ====================
local function StartAimbot()
    if aimbotConnection then return end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not Aiming then return end
        
        local closestChar = nil
        local closestDist = TriggerDistance + 1
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer == player then continue end
            
            local ready, char, rootPart = IsReady(otherPlayer.Character)
            if ready then
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local mousePos = Vector2.new(player:GetMouse().X, player:GetMouse().Y)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < closestDist then
                        closestDist = distance
                        closestChar = char
                    end
                end
            end
        end
        
        -- Apuntar al más cercano
        if closestChar then
            local _, _, targetPart = IsReady(closestChar)
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                CreateESP(closestChar)
            end
        end
    end)
end

local function StopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    ClearESP()
end

-- ==================== GUI ====================
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateSection("Aimbot")

CombatTab:CreateToggle({
    Name = "Aimbot (Apunta al más cercano)",
    CurrentValue = false,
    Callback = function(Value)
        Aiming = Value
        if Value then
            StartAimbot()
            Notify("Aimbot", "✅ Activado - Apuntando al más cercano")
        else
            StopAimbot()
            Notify("Aimbot", "❌ Desactivado")
        end
    end,
})

CombatTab:CreateSlider({
    Name = "Trigger Distance",
    Range = {60, 350},
    Increment = 10,
    CurrentValue = 150,
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
            Notify("ESP", "✅ Activado")
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    CreateESP(plr.Character)
                end
            end
        else
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
MenuTab:CreateLabel("Version: 1.14")
MenuTab:CreateLabel("Credits: ikgmonher")

Notify("IKGHUB v2", "Cargado - Aimbot Mejorado al Más Cercano")
