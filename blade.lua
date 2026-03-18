-- [[ AR2: PERFORMANCE OPTIMIZED (500 STUDS LIMIT) ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- 1. SETTINGS (Range Restricted)
_G.Aimbot = false
_G.ESP = false
local DETECT_RANGE = 500 -- 500 studs lang ang makikita at ma-a-aim
local AimPart = "Head"

-- 2. UI MENU
local ScreenGui = LP.PlayerGui:FindFirstChild("AR2_RangeUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "AR2_RangeUI"
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
createBtn("ESP", 68, function(s) _G.ESP = s end)

-- 3. RANGE-BASED LOGIC
local function getClosestInRange()
    local target, dist = nil, math.huge
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = LP.Character.HumanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(AimPart) then
            local enemyPos = p.Character[AimPart].Position
            local studDist = (myPos - enemyPos).Magnitude

            -- Check kung nasa 500 studs lang
            if studDist <= DETECT_RANGE then
                local screenPos, vis = Camera:WorldToViewportPoint(enemyPos)
                if vis then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then target = p.Character[AimPart]; dist = mag end
                end
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = LP.Character.HumanoidRootPart.Position

    -- RANGE-BASED ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hl = p.Character:FindFirstChild("Range_HL") or Instance.new("Highlight", p.Character)
            hl.Name = "Range_HL"
            
            local d = (myPos - p.Character.HumanoidRootPart.Position).Magnitude
            if _G.ESP and d <= DETECT_RANGE then
                hl.Enabled = true
                hl.FillColor = Color3.fromRGB(0, 255, 100) -- Green kung malapit
                hl.FillTransparency = 0.5
            else
                hl.Enabled = false -- Patay ang ESP pag malayo (Iwas lag)
            end
        end
    end

    -- AUTO AIM (RIGHT CLICK)
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getClosestInRange()
        if t then
            -- "Tutok na tutok" pero sumusunod sa position mo
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
        end
    end
end)
