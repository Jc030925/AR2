-- [[ BLADE BALL: BRUTE FORCE AUTO PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeForceUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeForceUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 200, 0, 50)
MainBtn.Position = UDim2.new(0.5, -100, 0.05, 0)
MainBtn.Text = "FORCE PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold
MainBtn.Draggable = true

local active = false
MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "FORCE PARRY: ON" or "FORCE PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(20, 20, 20)
end)

-- 2. PARRY EXECUTION
local function doParry()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- 3. SEARCH FOR BALL (Kahit saan nakatago)
local function findBall()
    -- I-scan ang buong workspace para sa bola
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Ball" or v:GetAttribute("realBall") or v.Name == "BaseBall" then
            if v:IsA("BasePart") then return v end
        end
    end
end

-- 4. LOGIC LOOP
RS.Heartbeat:Connect(function()
    if not active or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local ball = findBall()
    
    if hrp and ball then
        local dist = (ball.Position - hrp.Position).Magnitude
        local velocity = ball.Velocity.Magnitude
        
        -- TARGET CHECK
        local isTarget = false
        
        -- Check visual indicators (Highlight/Aura)
        for _, x in pairs(ball:GetDescendants()) do
            if x:IsA("Highlight") or x:IsA("SelectionBox") then
                local c = x:IsA("Highlight") and x.OutlineColor or x.Color3
                if c.R > 0.8 and c.G < 0.2 then
                    isTarget = true
                    break
                end
            end
        end

        -- KUNG TARGET KA:
        if isTarget then
            -- Dynamic calculation para sa speed
            local triggerDist = 18 + (velocity * 0.25)
            
            if dist <= triggerDist then
                doParry()
                task.wait(0.1)
            end
        end
        
        -- EMERGENCY PARRY (Kung sobrang dikit na kahit hindi red, baka lag lang)
        if dist <= 8 then
            doParry()
        end
    end
end)
