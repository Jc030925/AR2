-- [[ BLADE BALL: ULTRA AUTO PARRY + SPAM ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    Enabled = false,
    Range = 25, -- Taasan mo kung laging huli ang parry mo
    SpamDistance = 10 -- Kapag mas malapit pa dito, mag-i-spam na siya
}

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 200, 0, 50)
MainBtn.Position = UDim2.new(0.5, -100, 0.85, 0)
MainBtn.Text = "BLADE MODE: OFF"
MainBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.Draggable = true

MainBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    MainBtn.Text = Settings.Enabled and "BLADE MODE: ON" or "BLADE MODE: OFF"
    MainBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 0, 0)
end)

-- GET BALL FUNCTION
function getBall()
    for _, v in pairs(workspace:WaitForChild("Balls"):GetChildren()) do
        if v:GetAttribute("realBall") == true or v:FindFirstChild("Ball") then
            return v
        end
    end
end

-- PARRY EXECUTION
local function parry()
    -- I-fire ang Remote (ito ang standard sa Blade Ball)
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ParryButtonPress")
    if remote then
        remote:FireServer()
    else
        -- Fallback kung iba ang remote name
        pcall(function()
            ReplicatedStorage.Remotes.Parry:FireServer()
        end)
    end
end

-- MAIN LOOP
RS.Heartbeat:Connect(function()
    if not Settings.Enabled or not LP.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local ball = getBall()
    
    if ball and hrp then
        local dist = (ball.Position - hrp.Position).Magnitude
        local isTarget = (ball:GetAttribute("target") == LP.Name)
        
        -- Kung sa 'yo nakatutok ang bola
        if isTarget then
            -- Kung sobrang lapit na (Clash/Spam mode)
            if dist <= Settings.SpamDistance then
                parry()
            -- Kung sakto lang ang distansya base sa bilis
            elseif dist <= Settings.Range then
                parry()
            end
        end
    end
end)