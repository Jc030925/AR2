-- [[ AR2: STICKY AIM + ANTI-DETACH CAMERA ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- 1. SETTINGS
_G.Aimbot = false
_G.ESP = false
local DETECT_RANGE = 500 -- Distansya lang na ma-detect
local AimPart = "Head"

-- 2. UI MENU
local ScreenGui = LP.PlayerGui:FindFirstChild("AR2_FixedCamUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "AR2_FixedCamUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 100)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true 

local function createBtn(text, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

createBtn("AUTO AIM", 35, function(s) _G.Aimbot = s end)
createBtn("PLAYER ESP", 68, function(s) _G.ESP = s end)

-- 3. LOGIC (FIXED CAMERA ATTACHMENT)
local function getTarget()
    local target, dist = nil, math.huge
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(AimPart) then
            local enemyRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local d = (LP.Character.HumanoidRootPart.Position - enemyRoot.Position).Magnitude
                if d <= DETECT_RANGE then
                    local screenPos, vis = Camera:WorldToViewportPoint(p.Character[AimPart].Position)
                    if vis then
                        local mag = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation()).Magnitude
                        if mag < dist then target = p.Character[AimPart]; dist = mag end
                    end
                end
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LP.Character.HumanoidRootPart

    -- ESP (MALAPIT LANG)
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                hl.Enabled = (d <= DETECT_RANGE)
                hl.FillColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end

    -- AUTO AIM (RIGHT CLICK)
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getTarget()
        if t then
            -- ITO ANG FIX: Sabay ang Focus at CFrame sa player position
            local targetPos = t.Position
            local camPos = Camera.CFrame.Position
            
            -- Pinipilit sumunod ng camera focus sa RootPart mo para hindi ka maiwan
            Camera.Focus = myRoot.CFrame 
            Camera.CFrame = CFrame.lookAt(camPos, targetPos)
        end
    end
end)
