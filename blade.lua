-- [[ BLADE BALL: ADAPTIVE SPEED PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. PERMANENT UI
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeAdaptiveUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeAdaptiveUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 160, 0, 40)
MainBtn.Position = UDim2.new(0.5, -80, 0.02, 0)
MainBtn.Text = "ADAPTIVE PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

local active = false
local canParry = true

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "ADAPTIVE PARRY: ON" or "ADAPTIVE PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(20, 20, 20)
end)

-- 2. FAST EXECUTION
local function doParry()
    if not canParry then return end
    canParry = false
    
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    
    task.wait(0.01)
    
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    
    -- Mabilis na cooldown para sa high-speed rounds
    task.wait(0.35) 
    canParry = true
end

-- 3. ADAPTIVE LOGIC
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LP.Character.HumanoidRootPart
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end

    for _, ball in pairs(balls:GetChildren()) do
        -- Target Check (Attributes + Strict Color)
        local isTarget = ball:GetAttribute("target") == LP.Name
        if not isTarget then
            local hl = ball:FindFirstChildOfClass("Highlight")
            if hl and hl.OutlineColor.R > 0.8 and hl.OutlineColor.G < 0.2 then
                isTarget = true
            end
        end

        if isTarget and canParry then
            local relPos = (hrp.Position - ball.Position)
            local dist = relPos.Magnitude
            local vel = ball.Velocity.Magnitude
            
            -- Direction Check (Dapat papalapit)
            local isMovingTowards = ball.Velocity:Dot(relPos) > 0

            if isMovingTowards then
                -- === ADAPTIVE TIMING ===
                -- Kapag sobrang bilis ng bola, mas kailangan ng "Lead Time"
                -- 0.25 is the safety multiplier for high-speed ping
                local triggerDist = 12 + (vel * 0.25)
                
                -- Emergency buffer para sa "Curve" balls
                if vel > 150 then triggerDist = triggerDist + 5 end

                if dist <= triggerDist then
                    doParry()
                end
            end
        end
    end
end)
