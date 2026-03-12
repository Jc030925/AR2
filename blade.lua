-- [[ BLADE BALL: UNIVERSAL SCANNER + PURE VISUAL PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeUltraUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeUltraUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 160, 0, 40)
MainBtn.Position = UDim2.new(0.5, -80, 0.02, 0)
MainBtn.Text = "ULTRA PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
local lastParry = 0

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "ULTRA PARRY: ON" or "ULTRA PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(10, 10, 10)
end)

-- 2. PARRY EXECUTION
local function doParry()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    lastParry = tick()
end

-- 3. FIND BALL (Deep Scanner)
local function getBall()
    for _, v in pairs(workspace:GetDescendants()) do
        -- Hinahanap ang bola base sa pangalan o attributes ni Wiggity
        if (v.Name == "Ball" or v.Name == "BaseBall" or v:GetAttribute("realBall")) and v:IsA("BasePart") then
            return v
        end
    end
end

-- 4. MAIN DETECTION LOOP
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local ball = getBall()
    
    if ball then
        -- VISUAL CHECK: Hanapin kung nag-re-red ang Highlight/Aura (Targeting you)
        local isTarget = false
        local hl = ball:FindFirstChildOfClass("Highlight") or ball:FindFirstChildOfClass("SelectionBox")
        
        if hl then
            local color = hl:IsA("Highlight") and hl.OutlineColor or hl.Color3
            if color.R > 0.7 and color.G < 0.3 then -- Strict Red check
                isTarget = true
            end
        end

        -- Kung target ka, gawin ang Math
        if isTarget then
            local relPos = (hrp.Position - ball.Position)
            local dist = relPos.Magnitude
            local vel = ball.Velocity.Magnitude
            
            -- Direction Check (Dapat papalapit sa'yo)
            local isMovingTowards = ball.Velocity:Dot(relPos) > 0

            if isMovingTowards then
                -- TRIGGER DISTANCE (Adjusted for High Speed Skills)
                -- 14 baseline + 0.22 velocity factor
                local triggerDist = 14 + (vel * 0.22)
                
                -- Anti-Skill Buffer
                if vel > 120 then triggerDist = triggerDist + 5 end

                -- Cooldown Logic para sa Clash
                local cooldown = (dist < 12) and 0.02 or 0.4
                
                if dist <= triggerDist and (tick() - lastParry) >= cooldown then
                    doParry()
                end
            end
        end
    end
end)
