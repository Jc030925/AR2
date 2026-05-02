-- [[ GEMINI BEE BYPASS UI ]] --
local Library = {}
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "BeeGodUI"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 220, 0, 200)
Main.Position = UDim2.new(0.5, -110, 0.5, -100)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BEE INSTANT BYPASS"
Title.TextColor3 = Color3.new(1, 0.8, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

_G.AutoBypass = false

local btn = Instance.new("TextButton", Main)
btn.Size = UDim2.new(0.9, 0, 0, 50)
btn.Position = UDim2.new(0.05, 0, 0.3, 0)
btn.Text = "AUTO BYPASS: OFF"
btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btn.TextColor3 = Color3.new(1, 1, 1)

btn.MouseButton1Click:Connect(function()
    _G.AutoBypass = not _G.AutoBypass
    btn.Text = _G.AutoBypass and "AUTO BYPASS: ON" or "AUTO BYPASS: OFF"
    btn.BackgroundColor3 = _G.AutoBypass and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

-- [[ THE BYPASS LOGIC ]] --
-- Nakikinig tayo sa "BeeRollResult" para i-force trigger ang catch
game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(remote)
    if _G.AutoBypass and remote:IsA("RemoteEvent") and remote.Name == "BeeRollResult" then
        -- Kapag nakita ng script na may "BeeRoll" na nagaganap
        -- Susubukan nating i-fire ang lahat ng posibleng catch remotes
        local remotes = game:GetService("ReplicatedStorage")
        -- Palitan ang names sa ibaba kung may nakita kang bago sa F9
        pcall(function() remotes.Remotes.CatchBee:FireServer(true) end)
        pcall(function() remotes.Events.ClaimBee:FireServer() end)
        warn("Bypass Attempted on: " .. remote.Name)
    end
end)
