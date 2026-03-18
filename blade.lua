-- [[ APOCALYPSE RISING 2: RANGE AIM V3 ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- 1. SETTINGS & INDICATORS
_G.Aimbot = false
_G.ESP = false
local AimPart = "Head"
local MAX_AIM_DIST = 500 -- Studs: Limit ng Auto Aim range
local MAX_ESP_DIST = 1500 -- Studs: Limit ng Player ESP range

-- VISUAL FOV CIRCLE (Tulad nung sa Blade Ball picture mo, pero para sa AR2 Range)
local FovCircle = Instance.new("Part")
FovCircle.Shape = Enum.PartType.Cylinder
FovCircle.Material = Enum.Material.Neon
FovCircle.Color = Color3.fromRGB(85, 0, 255) -- Purple (Safe)
FovCircle.Transparency = 1 -- Hidden by default
FovCircle.CanCollide = false
FovCircle.Anchored = true
FovCircle.Parent = workspace
FovCircle.Size = Vector3.new(0.5, MAX_AIM_DIST * 2, MAX_AIM_DIST * 2)
FovCircle.Orientation = Vector3.new(0, 0, 90)

-- UI MENU
local ScreenGui = LP.PlayerGui:FindFirstChild("AR2_Menu")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "AR2_Menu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 160)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AR2 RANGE MASTER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(0, 200, 150) -- Teal Accent
Title.Font = Enum.Font.SourceSansBold

-- TOGGLE BUTTONS FUNCTION
local function createBtn(text, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

createBtn("RANGE AIM V3", 40, function(s) 
    _G.Aimbot = s 
    FovCircle.Transparency = s and 0.7 or 1 -- Show Circle if ON
end)
createBtn("PLAYER ESP", 80, function(s) _G.ESP = s end)
createBtn("INFINITE STAMINA", 120, function(s) 
    if s then LP.Character:SetAttribute("Fatigue", 0) end
end)

-- 2. RANGE-LIMITED TARGET FINDER
local function getBestTarget()
    local target, dist = nil, math.huge
    
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = LP.Character.HumanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(AimPart) and p.Character:FindFirstChild("HumanoidRootPart") then
            local enemyPos = p.Character[AimPart].Position
            local enemyDist = (myPos - enemyPos).Magnitude -- Range calculation in studs

            -- Check if enemy is within MAX_AIM_DIST
            if enemyDist <= MAX_AIM_DIST then
                local screenPos, vis = Camera:WorldToViewportPoint(enemyPos)
                if vis then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then 
                        target = p.Character[AimPart]; 
                        dist = mag 
                    end
                end
            end
        end
    end
    return target
end

-- 3. VISUALS & DETECT CYCLE
RS.Heartbeat:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LP.Character.HumanoidRootPart
    FovCircle.CFrame = myRoot.CFrame * CFrame.new(0, -3.2, 0) -- Follows you

    local currentTarget = getBestTarget()

    -- AIM Indicator (Change Circle Color if locked on target)
    if currentTarget and _G.Aimbot then
        FovCircle.Color = Color3.fromRGB(0, 255, 0) -- Green: TARGET IN RANGE
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position) -- Instant Snap
            -- Flash Green when Firing
            FovCircle.Color = Color3.fromRGB(255, 255, 255)
            task.delay(0.1, function() FovCircle.Color = Color3.fromRGB(0, 255, 0) end)
        end
    else
        FovCircle.Color = Color3.fromRGB(85, 0, 255) -- Purple: NO TARGET / SAFE
    end

    -- ESP UPDATE (Range Limited)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
            local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            
            -- Show ESP only if within MAX_ESP_DIST
            if dist <= MAX_ESP_DIST and _G.ESP then
                hl.Enabled = true
                hl.FillTransparency = 0.5
                -- Change color based on Aim Range (MAX_AIM_DIST)
                if dist <= MAX_AIM_DIST then
                    hl.FillColor = Color3.fromRGB(0, 255, 0) -- Green: Aimable
                else
                    hl.FillColor = Color3.fromRGB(255, 0, 0) -- Red: Outside Aim Range
                end
            else
                hl.Enabled = false
            end
        end
    end
end)
