-- [[ BLADE BALL: GLOW-TARGET AUTO PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI (Anti-Reset)
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeGlowUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeGlowUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 180, 0, 45)
MainBtn.Position = UDim2.new(0.5, -90, 0.05, 0)
MainBtn.Text = "GLOW PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold
MainBtn.Draggable = true

local active = false
MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "GLOW PARRY: ON" or "GLOW PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
end)

-- 2. PARRY EXECUTION (Hybrid Click)
local function executeParry()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0) -- Left Click
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game) -- F Key
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- 3. DETECTION LOOP (Based on Screenshot Aura)
RS.Heartbeat:Connect(function()
    if not active or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local balls = workspace:FindFirstChild("Balls")
    
    if hrp and balls then
        for _, ball in pairs(balls:GetChildren()) do
            -- Detection base sa Red Glow/Aura na nasa picture mo
            local isTarget = false
            
            -- Tinitignan yung Highlight o SelectionBox na kulay pula
            for _, child in pairs(ball:GetChildren()) do
                if (child:IsA("Highlight") or child:IsA("SelectionBox")) then
                    local color = child:IsA("Highlight") and child.OutlineColor or child.Color3
                    if color.R > 0.8 and color.G < 0.3 then -- Pure Red detection
                        isTarget = true
                        break
                    end
                end
            end
            
            if isTarget then
                local dist = (ball.Position - hrp.Position).Magnitude
                local velocity = ball.Velocity.Magnitude
                
                -- BASE RANGE: 16 studs (adjust mo 'to kung masiyadong maaga/huli)
                -- VELOCITY MULTIPLIER: 0.22 (dagdagan mo para mas maaga ang parry)
                local triggerDist = 16 + (velocity * 0.22)
                
                if dist <= triggerDist then
                    executeParry()
                    task.wait(0.12) -- Prevent spam detection
                end
            end
        end
    end
end)
