-- [[ BLADE BALL: UNIVERSAL AUTO PARRY ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    Enabled = false,
    Range = 35, -- Tinaasan ko para mas safe sa ping
    SpamRange = 12
}

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 200, 0, 50)
MainBtn.Position = UDim2.new(0.5, -100, 0.1, 0) -- Nilagay ko sa taas para hindi harang
MainBtn.Text = "AUTO PARRY: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Draggable = true

MainBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    MainBtn.Text = Settings.Enabled and "AUTO PARRY: ON" or "AUTO PARRY: OFF"
    MainBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

-- GET REMOTE FUNCTION (Hahanapin natin yung tamang pinto)
local function getParryRemote()
    local remoteNames = {"ParryButtonPress", "Parry", "ParryRemote", "Reflect", "Block"}
    for _, name in pairs(remoteNames) do
        local r = ReplicatedStorage:FindFirstChild(name, true) -- 'true' para hanapin kahit sa loob ng folders
        if r and r:IsA("RemoteEvent") then return r end
    end
end

local parryRemote = getParryRemote()

-- MAIN LOOP
RS.Heartbeat:Connect(function()
    if not Settings.Enabled or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local ballsFolder = workspace:FindFirstChild("Balls")
    
    if ballsFolder and hrp then
        for _, ball in pairs(ballsFolder:GetChildren()) do
            -- Detection kung sa'yo ang bola (Attribute check)
            local target = ball:GetAttribute("target") or ball:GetAttribute("Target")
            
            if target == LP.Name then
                local dist = (ball.Position - hrp.Position).Magnitude
                local velocity = ball.Velocity.Magnitude
                
                -- Dynamic adjustment base sa bilis ng bola
                local activationDist = Settings.Range + (velocity * 0.2)
                
                if dist <= activationDist then
                    -- EXECUTE PARRY
                    if parryRemote then
                        parryRemote:FireServer()
                    else
                        -- Fallback: Virtual Click kung walang remote na mahanap
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    end
                end
            end
        end
    end
end)
