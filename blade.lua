-- [[ BLADE BALL: LAG-FREE PERFORMANCE PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. UI SETUP (ANTI-LAG)
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeFinalUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeFinalUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 160, 0, 40)
MainBtn.Position = UDim2.new(0.5, -80, 0.02, 0)
MainBtn.Text = "AUTO PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
local lastParry = 0

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "AUTO PARRY: ON" or "AUTO PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(20, 20, 20)
end)

-- 2. PRECISION PARRY
local function doParry()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    lastParry = tick()
end

-- 3. OPTIMIZED BALL TRACKER
local function findBall()
    -- Mas mabilis ito kaysa sa GetDescendants
    local b = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("Ball")
    if b then
        if b:IsA("BasePart") then return b end
        return b:FindFirstChildOfClass("BasePart") or b:FindFirstChild("Ball")
    end
    -- Fallback sa common folder
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Balls" or v.Name == "Ball" then
            return v:IsA("BasePart") and v or v:FindFirstChildOfClass("BasePart")
        end
    end
end

-- 4. SMART DETECTION LOOP
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local ball = findBall()
    
    if ball then
        -- Strict Target Detection (Visual Focus)
        local isTarget = false
        local hl = ball:FindFirstChildOfClass("Highlight") or ball:FindFirstChildOfClass("SelectionBox")
        
        if hl then
            local color = hl:IsA("Highlight") and hl.OutlineColor or hl.Color3
            -- Red detection based on your screenshot
            if color.R > 0.8 and color.G < 0.2 then
                isTarget = true
            end
        end

        if isTarget then
            local relPos = (hrp.Position - ball.Position)
            local dist = relPos.Magnitude
            local vel = ball.Velocity.Magnitude
            
            -- Direction: Is it coming towards you?
            local isComing = ball.Velocity:Dot(relPos) > 0

            if isComing then
                -- Trigger Distance based on Ping & Velocity
                -- 12 base + velocity scaling
                local trigger = 12 + (vel * 0.22)
                
                -- Anti-Skill / High Speed Buffer
                if vel > 130 then trigger = trigger + 6 end

                -- Adaptive Cooldown (Clash vs Normal)
                local cd = (dist < 15) and 0.02 or 0.45

                if dist <= trigger and (tick() - lastParry) >= cd then
                    doParry()
                end
            end
        end
    end
end)
