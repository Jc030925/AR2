-- [[ BLADE BALL: SMOOTH SINGLE-PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeSmoothUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeSmoothUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 160, 0, 40)
MainBtn.Position = UDim2.new(0.5, -80, 0.02, 0)
MainBtn.Text = "AUTO PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
local canParry = true -- Eto ang mag-aayos ng double parry

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "AUTO PARRY: ON" or "AUTO PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

-- 2. CLEAN PARRY EXECUTION
local function doParry()
    if not canParry then return end
    canParry = false -- Lock muna para hindi mag-double
    
    -- Isang mabilis na "Press and Release"
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    
    task.wait(0.01)
    
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    
    -- Cooldown: 0.5 seconds bago pwedeng mag-parry ulit (Para iwas double-flick)
    task.wait(0.5) 
    canParry = true
end

-- 3. DETECTION LOOP
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end

    for _, ball in pairs(balls:GetChildren()) do
        -- Check if target
        local isTarget = ball:GetAttribute("target") == LP.Name
        if not isTarget then
            local hl = ball:FindFirstChildOfClass("Highlight")
            if hl and hl.OutlineColor.R > 0.9 and hl.OutlineColor.G < 0.1 then
                isTarget = true
            end
        end

        if isTarget and canParry then
            local relPos = (hrp.Position - ball.Position)
            local isMovingTowards = ball.Velocity:Dot(relPos) > 0

            if isMovingTowards then
                local dist = relPos.Magnitude
                local vel = ball.Velocity.Magnitude
                
                -- Prediction logic
                local triggerDist = 14 + (vel * 0.22) 
                
                if dist <= triggerDist then
                    doParry()
                end
            end
        end
    end
end)
