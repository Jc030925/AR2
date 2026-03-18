-- [[ APOCALYPSE RISING 2: CLEAN AIM + ESP ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- 1. SETTINGS
_G.Aimbot = false
_G.ESP = false
local AimPart = "Head" -- Pwede mong gawing "UpperTorso" kung gusto mo mas legit

-- 2. UI MENU (Simple & Clean)
local ScreenGui = LP.PlayerGui:FindFirstChild("AR2_CleanUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "AR2_CleanUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 100)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true 

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "AR2 EXTERNAL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.SourceSansBold

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
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

createBtn("AIMBOT", 35, function(s) _G.Aimbot = s end)
createBtn("ESP", 68, function(s) _G.ESP = s end)

-- 3. LOGIC (AIM & ESP)
local function getClosest()
    local target, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(AimPart) then
            local pos, vis = Camera:WorldToViewportPoint(p.Character[AimPart].Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then target = p.Character[AimPart]; dist = mag end
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    -- AIMBOT (Right Click to Snap)
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getClosest()
        if t then 
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) 
        end
    end
    
    -- ESP UPDATE (Pure Highlight)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hl = p.Character:FindFirstChild("ESP_Highlight") or Instance.new("Highlight", p.Character)
            hl.Name = "ESP_Highlight"
            hl.Enabled = _G.ESP
            hl.FillColor = Color3.fromRGB(255, 0, 0) -- Red Glow
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
        end
    end
end)
