-- [[ SIMPLE SMOOTH FLY - PRESS F TO TOGGLE ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local UserInputService = game:GetService("UserInputService")

local flying = false
local speed = 50 -- Baguhin mo 'to kung gusto mo mas mabilis

local bv, bg
local char, root

local function startFly()
    char = LP.Character
    root = char:FindFirstChild("HumanoidRootPart")
    
    if not root then return end
    
    -- Anti-Gravity / Velocity Setup
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
    bg.CFrame = root.CFrame
    bg.Parent = root
    
    LP.Character.Humanoid.PlatformStand = true
    
    repeat
        task.wait()
        -- Control Logic
        local moveDir = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + (workspace.CurrentCamera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - (workspace.CurrentCamera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - (workspace.CurrentCamera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + (workspace.CurrentCamera.CFrame.RightVector)
        end
        
        bv.Velocity = moveDir * speed
        bg.CFrame = workspace.CurrentCamera.CFrame
    until not flying
    
    -- Clean up pag off na
    bv:Destroy()
    bg:Destroy()
    LP.Character.Humanoid.PlatformStand = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        if flying then
            task.spawn(startFly)
        end
    end
end)
