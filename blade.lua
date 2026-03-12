-- [[ BLADE BALL: ADAPTIVE + CLASH SPAM MODE ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeClashUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeClashUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 160, 0, 40)
MainBtn.Position = UDim2.new(0.5, -80, 0.02, 0)
MainBtn.Text = "CLASH MODE: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
local canParry = true
local isClashing = false

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "CLASH MODE: ON" or "CLASH MODE: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(20, 20, 20)
end)

-- 2. PARRY & SPAM EXECUTION
local function doParry(spam)
    if not canParry and not spam then return end
    if not spam then canParry = false end
    
    -- Fast Click + F
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait()
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    
    if not spam then
        task.wait(0.3) -- Standard cooldown
        canParry = true
    end
end

-- 3. DETECTION LOOP
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end

    for _, ball in pairs(balls:GetChildren()) do
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
                -- === CLASH DETECTION ===
                -- Kapag ang bola ay nasa loob ng 10 studs, automatic SPAM mode
                if dist <= 10 then
                    doParry(true) -- True means ignore cooldown (SPAM)
                else
                    -- === NORMAL ADAPTIVE MODE ===
                    local triggerDist = 12 + (vel * 0.26)
                    if dist <= triggerDist and canParry then
                        doParry(false)
                    end
                end
            end
        end
    end
end)
