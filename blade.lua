-- [[ AR2: STICKY AUTO AIM + FIXED CAMERA FOLLOW ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- 1. SETTINGS
_G.Aimbot = false
_G.ESP = false
local AimPart = "Head"

-- 2. UI MENU
local ScreenGui = LP.PlayerGui:FindFirstChild("AR2_FinalUI")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "AR2_FinalUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 100)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

createBtn("AUTO AIM", 35, function(s) _G.Aimbot = s end)
createBtn("ESP", 68, function(s) _G.ESP = s end)

-- 3. UPDATED LOGIC (HINDI NA STUCK ANG CAMERA)
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
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getClosest()
        if t and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            -- Pinipilit ang camera na tumingin sa target habang naka-attach sa player
            local lookAtPos = t.Position
            local camPos = Camera.CFrame.Position
            
            -- Ito ang sekreto: CFrame.lookAt na hindi binabago ang distansya ng camera
            Camera.CFrame = CFrame.lookAt(camPos, lookAtPos)
        end
    else
        -- Binabalik ang control sa Roblox para hindi ma-stuck ang camera
        Camera.CameraType = Enum.CameraType.Custom
    end
    
    -- CLEAN ESP
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hl = p.Character:FindFirstChild("ESP_Highlight") or Instance.new("Highlight", p.Character)
                hl.Name = "ESP_Highlight"
                hl.Enabled = true
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.5
            end
        end
    end
end)
