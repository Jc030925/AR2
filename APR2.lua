-- [[ GEMINI BEE BYPASS + TP AUTO FARM ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Bee God - Instant Bypass", "Midnight")

-- Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CatchService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CatchService --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

_G.AutoFarm = false

-- [[ FUNCTIONS ]] --
local function bypassMinigame()
    -- Ito ang force-complete sa sliding game
    pcall(function()
        CatchService.RF.NotifyMinigameCompleted:InvokeServer()
    end)
end

local function startFarm()
    spawn(function()
        while _G.AutoFarm do
            task.wait(0.5)
            -- Hanapin ang lahat ng Bees sa Workspace (Palitan ang "Bee" kung iba name sa Dex)
            for _, bee in pairs(game.Workspace:GetChildren()) do
                if _G.AutoFarm == false then break end
                
                -- Check kung Bee talaga (Dapat may PrimaryPart o Part)
                if bee:FindFirstChild("HumanoidRootPart") or bee.Name:find("Bee") then
                    -- 1. Teleport sa Bee
                    LP.Character.HumanoidRootPart.CFrame = bee:GetModelCFrame() or bee.CFrame
                    task.wait(0.2)
                    
                    -- 2. Dito ilalagay yung Remote para i-trigger ang huli
                    -- (Dahil Knit ito, auto-trigger na madalas basta malapit ka)
                    
                    -- 3. Instant Bypass ang Sliding Game
                    bypassMinigame()
                    warn("Bypassed minigame for: " .. bee.Name)
                end
            end
        end
    end)
end

-- [[ UI TABS ]] --
local Main = Window:NewTab("Main Farm")
local Section = Main:NewSection("Auto Bee Catch")

Section:NewToggle("Auto TP + Instant Catch", "Teleports to bees and skips minigame", function(state)
    _G.AutoFarm = state
    if state then
        startFarm()
    end
end)

Section:NewButton("Manual Instant Bypass", "Force skip current sliding game", function()
    bypassMinigame()
end)

Library:Notify("Script Loaded! Ready to catch.")
