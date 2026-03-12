-- [[ BLADE BALL: HYBRID VISUAL PARRY (F + LEFT CLICK) ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI SETUP
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeHybridUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BladeHybridUI"
ScreenGui.Parent = LP.PlayerGui
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 200, 0, 50)
MainBtn.Position = UDim2.new(0.5, -100, 0.05, 0)
MainBtn.Text = "ULTRA PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "ULTRA PARRY: ON" or "ULTRA PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)

-- 2. HYBRID PARRY FUNCTION (F + Mouse Click)
local function doParry()
    -- Simulates "F" Key
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    -- Simulates "Left Click"
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    
    task.wait(0.01)
    
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- 3. DETECTION LOOP
RS.RenderStepped:Connect(function()
    if not active or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local balls = workspace:FindFirstChild("Balls")
    
    if hrp and balls then
        for _, ball in pairs(balls:GetChildren()) do
            -- Red Highlight Check
            local highlight = ball:FindFirstChildOfClass("Highlight")
            if highlight and (highlight.OutlineColor.R > 0.7) then
                local dist = (ball.Position - hrp.Position).Magnitude
                local velocity = ball.Velocity.Magnitude
                
                -- Dynamic Range: I-adjust mo ito kung masiyadong maaga o huli
                local triggerDist = 18 + (velocity * 0.2)
                
                if dist <= triggerDist then
                    doParry()
                    task.wait(0.15) -- Anti-spam delay
                end
            end
        end
    end
end)
