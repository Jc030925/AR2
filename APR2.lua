local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Bee God v2 - Instant Bypass", "Midnight")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Remote paths base sa Dex screenshots mo
local KnitServices = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services
local CatchService = KnitServices.CatchService
local InteractionService = KnitServices.InteractionService -- Gagamitin para sa click

_G.AutoFarm = false

local function instantBypass()
    -- Ito ang force-complete sa sliding game na nakita natin sa image_d09a3f.png
    pcall(function()
        CatchService.RF.NotifyMinigameCompleted:InvokeServer()
    end)
end

local function startFarm()
    spawn(function()
        while _G.AutoFarm do
            task.wait(0.3)
            for _, bee in pairs(game.Workspace:GetChildren()) do
                if not _G.AutoFarm then break end
                
                -- Check kung Bee (Model or Part)
                if bee:IsA("Model") and (bee.Name:find("Bee") or bee:FindFirstChild("HumanoidRootPart")) then
                    local targetPos = bee:GetModelCFrame()
                    
                    -- 1. Teleport sa harap ng Bee
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos * CFrame.new(0, 0, 3)
                    task.wait(0.1)
                    
                    -- 2. Auto-Click/Interact (Para lumabas yung "Slide to Catch")
                    pcall(function()
                        InteractionService.RF.Interact:InvokeServer(bee)
                    end)
                    
                    -- 3. Instant Bypass (Para mawala agad yung bar sa screenshot mo)
                    task.wait(0.1)
                    instantBypass()
                    
                    warn("Caught and Bypassed: " .. bee.Name)
                    task.wait(0.5) -- Konting delay para hindi mag-lag
                end
            end
        end
    end)
end

local Main = Window:NewTab("Main Farm")
local Section = Main:NewSection("Bee Catching")

Section:NewToggle("Auto TP + Click + Bypass", "Full automation", function(state)
    _G.AutoFarm = state
    if state then startFarm() end
end)

Section:NewButton("Manual Bypass (Use when bar is visible)", "Force skip current bar", function()
    instantBypass()
end)
