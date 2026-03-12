-- [[ BLADE BALL: SMOOTH REPEATABLE PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    Enabled = false,
    Range = 30, 
    Prediction = 0.25 -- Dagdag na distansya base sa bilis ng bola
}

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 180, 0, 45)
MainBtn.Position = UDim2.new(0.5, -90, 0.05, 0)
MainBtn.Text = "SMOOTH PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Draggable = true

MainBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    MainBtn.Text = Settings.Enabled and "SMOOTH PARRY: ON" or "SMOOTH PARRY: OFF"
    MainBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(35, 35, 35)
end)

-- GET REMOTE (Deep Scan)
local function getRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:find("Parry") or v.Name:find("Block") or v.Name:find("Reflect")) then
            return v
        end
    end
end

local parryRemote = getRemote()

-- PARRY FUNCTION
local function fireParry()
    if parryRemote then
        parryRemote:FireServer()
    else
        -- Backup Virtual Press
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

-- ULTIMATE LOOP
RS.PreRender:Connect(function() -- Mas mabilis kaysa Heartbeat
    if not Settings.Enabled or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local balls = workspace:FindFirstChild("Balls")
    
    if hrp and balls then
        for _, ball in pairs(balls:GetChildren()) do
            -- Tinitignan kung PULA o sa'yo nakatutok ang bola
            local isTarget = ball:GetAttribute("target") == LP.Name or ball:GetAttribute("Target") == LP.Name
            
            -- Alternative: Check if ball is red (some games use this)
            if not isTarget and ball:FindFirstChild("Highlight") then
                if ball.Highlight.OutlineColor == Color3.new(1, 0, 0) then
                    isTarget = true
                end
            end

            if isTarget then
                local dist = (ball.Position - hrp.Position).Magnitude
                local velocity = ball.Velocity.Magnitude
                
                -- Dynamic Range: Kung mabilis ang bola, mas malayo pa lang papitik na
                local effectiveRange = Settings.Range + (velocity * Settings.Prediction)
                
                if dist <= effectiveRange then
                    fireParry()
                    task.wait(0.05) -- Konting hinga para hindi ma-kick pero mabilis pa rin
                end
            end
        end
    end
end)
