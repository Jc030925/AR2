-- [[ BLADE BALL: PRO-TTI DETECTION (LAG-COMPENSATED) ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeProUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeProUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 160, 0, 40)
MainBtn.Position = UDim2.new(0.5, -80, 0.02, 0)
MainBtn.Text = "PRO PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
local lastParry = 0

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "PRO PARRY: ON" or "PRO PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(85, 0, 255) or Color3.fromRGB(15, 15, 15)
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

-- 3. THE "BRAIN" (TTI LOGIC)
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end

    for _, ball in pairs(balls:GetChildren()) do
        -- Visual & Attribute Detection
        local isTarget = ball:GetAttribute("target") == LP.Name
        if not isTarget then
            local hl = ball:FindFirstChildOfClass("Highlight")
            if hl and hl.OutlineColor.R > 0.8 and hl.OutlineColor.G < 0.2 then
                isTarget = true
            end
        end

        if isTarget then
            local ballPos = ball.Position
            local ballVel = ball.Velocity
            local charPos = hrp.Position
            
            local relPos = (charPos - ballPos)
            local dist = relPos.Magnitude
            
            -- Direction Check: Siguradong papunta sa'yo
            local dot = ballVel.Unit:Dot(relPos.Unit)
            
            if dot > 0.65 then -- High precision angle (0.65+ means it's coming at you)
                local speed = ballVel.Magnitude
                
                -- TIME TO IMPACT (TTI)
                -- Eto yung sikreto: Distance divided by Speed = Seconds left
                local tti = dist / speed
                
                -- ADJUSTABLE THRESHOLD (Ping Compensation)
                -- 0.12 to 0.15 is the sweet spot. 
                -- Taasan mo (e.g. 0.18) kung late ka lagi. Babaan kung advance.
                local parryThreshold = 0.135 
                
                -- Dynamic Buffer: Mas maaga ng konti kung sobrang bilis ng bola
                if speed > 150 then
                    parryThreshold = 0.15
                end

                -- Clash/Spam Detection
                local isClash = dist < 12
                local cooldown = isClash and 0.01 or 0.4

                if (tti <= parryThreshold or dist < 8) and (tick() - lastParry) >= cooldown then
                    doParry()
                end
            end
        end
    end
end)
