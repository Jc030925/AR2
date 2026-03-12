-- [[ BLADE BALL: PURE TARGET VISUAL PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI SETUP
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeStrictUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BladeStrictUI"
ScreenGui.Parent = LP.PlayerGui
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 200, 0, 50)
MainBtn.Position = UDim2.new(0.5, -100, 0.05, 0)
MainBtn.Text = "STRICT PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "STRICT PARRY: ON" or "STRICT PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

-- 2. PARRY EXECUTION
local function doParry()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- 3. DETECTION LOOP
RS.Heartbeat:Connect(function() -- Ginamit natin Heartbeat para mas accurate sa physics
    if not active or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local balls = workspace:FindFirstChild("Balls")
    
    if hrp and balls then
        for _, ball in pairs(balls:GetChildren()) do
            -- Hanapin ang Highlight o SelectionBox (Visual Target)
            local targetObj = ball:FindFirstChildOfClass("Highlight") or ball:FindFirstChildOfClass("SelectionBox")
            
            if targetObj then
                local color = targetObj:IsA("Highlight") and targetObj.OutlineColor or targetObj.Color3
                
                -- STRICT COLOR CHECK: Dapat dominant ang RED.
                -- Kung Puti ang bola (1,1,1), hindi ito mag-tru-true kasi kailangang mababa ang Green at Blue.
                local isRealTarget = (color.R > 0.8) and (color.G < 0.2) and (color.B < 0.2)
                
                if isRealTarget then
                    local dist = (ball.Position - hrp.Position).Magnitude
                    local velocity = ball.Velocity.Magnitude
                    
                    -- Dynamic Threshold: 16 studs baseline + prediction
                    local triggerDist = 16 + (velocity * 0.21)
                    
                    if dist <= triggerDist then
                        doParry()
                        task.wait(0.12) -- Cooldown para hindi ma-spam
                    end
                end
            end
        end
    end
end)
