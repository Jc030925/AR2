-- [[ AR2: ANCHORED CAMERA AIM + RANGE ESP ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- 1. SETTINGS
_G.Aimbot = false
_G.ESP = false
local RANGE = 500 -- 500 studs limit para iwas lag
local AimPart = "Head"

-- 2. UI MENU
local ScreenGui = LP.PlayerGui:FindFirstChild("AR2_AnchorUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "AR2_AnchorUI"
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

-- 3. LOGIC (FIXED CAMERA ANCHOR)
local function getClosest()
    local target, dist = nil, math.huge
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(AimPart) then
            local d = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d <= RANGE then
                local pos, vis = Camera:WorldToViewportPoint(p.Character[AimPart].Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then target = p.Character[AimPart]; dist = mag end
                end
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local Root = LP.Character.HumanoidRootPart

    -- ESP UPDATE (MALAPIT LANG)
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (Root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                hl.Enabled = (d <= RANGE)
                hl.FillColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end

    -- FIXED AUTO AIM (Right Click)
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getClosest()
        if t then
            -- ITO ANG FIX: Kinukuha ang distansya ng camera mo sa character (Offset)
            local offset = Camera.CFrame.Position - Root.Position
            
            -- Ina-apply ang lookAt pero pinapanatili ang offset para sumunod ang camera
            Camera.Focus = Root.CFrame
            Camera.CFrame = CFrame.lookAt(Root.Position + offset, t.Position)
        end
    end
end)
