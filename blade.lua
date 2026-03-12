-- [[ BLADE BALL: DYNAMIC VISUALIZER + AUTO-PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- 1. UI SETUP
local ScreenGui = LP.PlayerGui:FindFirstChild("BladeVisualUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "BladeVisualUI"
ScreenGui.ResetOnSpawn = false 

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 160, 0, 40)
MainBtn.Position = UDim2.new(0.5, -80, 0.02, 0)
MainBtn.Text = "VISUAL PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Font = Enum.Font.SourceSansBold

-- 2. CREATE THE VISUAL CIRCLE (Tulad ng nasa picture mo)
local VisualPart = Instance.new("Part")
VisualPart.Shape = Enum.PartType.Cylinder
VisualPart.Material = Enum.Material.Neon
VisualPart.Color = Color3.fromRGB(255, 0, 0) -- Red Circle
VisualPart.Transparency = 0.7
VisualPart.CanCollide = false
VisualPart.Anchored = true
VisualPart.Parent = workspace
VisualPart.Size = Vector3.new(0.5, 0, 0)
VisualPart.Orientation = Vector3.new(0, 0, 90)

local active = false
local lastParry = 0

MainBtn.MouseButton1Click:Connect(function()
    active = not active
    MainBtn.Text = active and "VISUAL PARRY: ON" or "VISUAL PARRY: OFF"
    MainBtn.BackgroundColor3 = active and Color3.fromRGB(255, 0, 80) or Color3.fromRGB(20, 20, 20)
    VisualPart.Transparency = active and 0.7 or 1
end)

-- 3. PARRY LOGIC
local function doParry()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    lastParry = tick()
end

-- 4. MAIN LOOP (VISUALS + DETECTION)
RS.Heartbeat:Connect(function()
    if not active or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
        VisualPart.Transparency = 1
        return 
    end
    
    local hrp = LP.Character.HumanoidRootPart
    VisualPart.CFrame = hrp.CFrame * CFrame.new(0, -3, 0) -- Nasa paanan mo
    
    local balls = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("Ball")
    local currentBall = nil
    
    -- Hanapin ang active ball
    if balls then
        currentBall = balls:IsA("BasePart") and balls or balls:FindFirstChildOfClass("BasePart")
    end

    if currentBall then
        local relPos = (hrp.Position - currentBall.Position)
        local dist = relPos.Magnitude
        local vel = currentBall.Velocity.Magnitude
        
        -- DYNAMIC RANGE CALCULATION
        -- Habang mas mabilis (vel), mas malaki ang radius
        local radius = 12 + (vel * 0.22)
        if vel > 120 then radius = radius + 5 end -- Skill compensation
        
        -- Update Visual Circle Size
        VisualPart.Size = Vector3.new(0.2, radius * 2, radius * 2)
        VisualPart.Transparency = 0.7

        -- TARGET CHECK (Visual Red)
        local isTarget = false
        local hl = currentBall:FindFirstChildOfClass("Highlight")
        if hl and hl.OutlineColor.R > 0.8 then isTarget = true end

        if isTarget and currentBall.Velocity:Dot(relPos) > 0 then
            -- Cooldown para smooth sa clash
            local cd = (dist < 15) and 0.05 or 0.4
            
            if dist <= radius and (tick() - lastParry) >= cd then
                doParry()
                VisualPart.Color = Color3.fromRGB(255, 255, 255) -- Flash White pag pumalo
                task.delay(0.1, function() VisualPart.Color = Color3.fromRGB(255, 0, 0) end)
            end
        end
    else
        VisualPart.Size = Vector3.new(0.2, 0, 0) -- Small pag walang bola
    end
end)
