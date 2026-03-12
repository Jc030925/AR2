-- [[ BLADE BALL: SMOOTH CLASH & PARRY ]] --
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
local lastParry = 0 -- Gagamitin natin 'to imbes na task.wait para walang lag

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "AUTO PARRY: ON" or "AUTO PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

-- 2. CLEAN PARRY EXECUTION
local function doParry()
    -- Isang click lang talaga
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    
    task.wait(0.01)
    
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    
    lastParry = tick() -- I-record kung kailan huling pumalo
end

-- 3. DETECTION LOOP
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end

    for _, ball in pairs(balls:GetChildren()) do
        -- Target Check
        local isTarget = ball:GetAttribute("target") == LP.Name
        if not isTarget then
            local hl = ball:FindFirstChildOfClass("Highlight")
            if hl and hl.OutlineColor.R > 0.9 and hl.OutlineColor.G < 0.1 then
                isTarget = true
            end
        end

        if isTarget then
            local relPos = (hrp.Position - ball.Position)
            local dist = relPos.Magnitude
            local vel = ball.Velocity.Magnitude
            
            -- Direction Check (Dapat papalapit)
            local isMovingTowards = ball.Velocity:Dot(relPos) > 0

            if isMovingTowards then
                -- === ADJUSTED TIMING (Hindi Advance) ===
                -- Binabaan natin ang 14 to 11 para saktong lapit bago pumalo
                -- Binabaan din ang multiplier mula 0.22 to 0.19 para hindi advance
                local triggerDist = 11 + (vel * 0.19)
                
                -- Clash Mode: Kapag dikit na (Clash), mas mabilis ang cooldown
                local cooldown = (dist <= 15) and 0.05 or 0.45
                
                if dist <= triggerDist and (tick() - lastParry) >= cooldown then
                    doParry()
                end
            end
        end
    end
end)
