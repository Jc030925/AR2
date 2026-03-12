-- [[ BLADE BALL (WIGGITY) - PERMANENT UI + SMOOTH PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. FIXED UI (Hindi na mawawala pag namatay)
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BladeUI"
ScreenGui.Parent = LP.PlayerGui
ScreenGui.ResetOnSpawn = false -- Eto ang sikreto para hindi mawala

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 180, 0, 45)
MainBtn.Position = UDim2.new(0.5, -90, 0.05, 0)
MainBtn.Text = "AUTO PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "AUTO PARRY: ON" or "AUTO PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

-- 2. WIGGITY DETECTION (Special for Original Game)
local function getBall()
    for _, b in pairs(workspace.Balls:GetChildren()) do
        if b:GetAttribute("realBall") == true then
            return b
        end
    end
end

local function parry()
    -- Ginagamit natin yung pinakabagong Remote ng Wiggity
    local r1 = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")
    local r2 = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryAttempt")
    
    if r1 then r1:FireServer() end
    if r2 then r2:FireServer() end
    
    -- Backup physical click
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
end

-- 3. SMOOTH LOOP (No Delay)
RS.PreRender:Connect(function()
    if not active or not LP.Character then return end
    
    local ball = getBall()
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    
    if ball and hrp then
        local target = ball:GetAttribute("target")
        if target == LP.Name then
            local dist = (ball.Position - hrp.Position).Magnitude
            local velocity = ball.Velocity.Magnitude
            
            -- Dynamic Prediction (Para sa mabilis na bola)
            local threshold = 20 + (velocity * 0.15)
            
            if dist <= threshold then
                parry()
            end
        end
    end
end)
