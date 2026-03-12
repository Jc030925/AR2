-- [[ BLADE BALL: SKILL-COUNTER & SMOOTH CLASH ]] --
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
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
local lastParry = 0

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "ULTRA PARRY: ON" or "ULTRA PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

-- 2. FAST PARRY EXECUTION
local function doParry()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    lastParry = tick()
end

-- 3. ADVANCED DETECTION
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end

    for _, ball in pairs(balls:GetChildren()) do
        -- Strict Target Check
        local isTarget = ball:GetAttribute("target") == LP.Name
        if not isTarget then
            local hl = ball:FindFirstChildOfClass("Highlight")
            if hl and hl.OutlineColor.R > 0.8 and hl.OutlineColor.G < 0.2 then
                isTarget = true
            end
        end

        if isTarget then
            local relPos = (hrp.Position - ball.Position)
            local dist = relPos.Magnitude
            local vel = ball.Velocity.Magnitude
            
            -- Direction Check
            local isMovingTowards = ball.Velocity:Dot(relPos) > 0

            if isMovingTowards then
                -- === SKILL & SPEED COMPENSATION ===
                -- Dynamic Offset: Habang bumibilis (Skills), lalong lumalawak ang detection
                -- Ginamit ko ang 0.21 multiplier para hindi masyadong advance pero sapat sa bilis
                local triggerDist = 12 + (vel * 0.21)
                
                -- Extra Buffer para sa mga "Raging" o "Fast" skills
                if vel > 120 then
                    triggerDist = triggerDist + 4 -- Dagdag distansya para sa skills
                end

                -- Cooldown Logic: 
                -- Kapag sobrang bilis na (Skill rounds), tinatanggal natin ang cooldown para makasabay
                local cooldownLimit = (vel > 100) and 0.02 or 0.4
                
                if dist <= triggerDist and (tick() - lastParry) >= cooldownLimit then
                    doParry()
                end
            end
        end
    end
end)
