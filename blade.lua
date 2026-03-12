-- [[ BLADE BALL: STRICT VISUAL PARRY (TARGET ONLY) ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI
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
MainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "STRICT PARRY: ON" or "STRICT PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

-- 2. HYBRID PARRY FUNCTION
local function doParry()
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- 3. STRICT DETECTION LOOP
RS.RenderStepped:Connect(function()
    if not active or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local balls = workspace:FindFirstChild("Balls")
    
    if hrp and balls then
        for _, ball in pairs(balls:GetChildren()) do
            local highlight = ball:FindFirstChildOfClass("Highlight")
            
            if highlight then
                local color = highlight.OutlineColor
                -- STRICT COLOR CHECK: Dapat dominant ang RED (R=1, G=0, B=0)
                -- Kapag puti o ibang kulay ang highlight, hindi ito mag-trigger.
                local isStrictTarget = (color.R > 0.9 and color.G < 0.1 and color.B < 0.1)

                if isStrictTarget then
                    local dist = (ball.Position - hrp.Position).Magnitude
                    local velocity = ball.Velocity.Magnitude
                    
                    -- DISTANCE CALCULATION
                    local triggerDist = 15 + (velocity * 0.18)
                    
                    if dist <= triggerDist then
                        doParry()
                        task.wait(0.15) -- Delay para hindi mag-spam kung malayo pa
                    end
                end
            end
        end
    end
end)
