-- Simple Logger for Xeno
print("LOGGING STARTED...")

local RemoteEvent = game:IsA("RemoteEvent") -- check para sa events

for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        v.OnClientEvent:Connect(function(...)
            warn("REMOTE RECEIVED: " .. v.Name)
            print("DATA: ", ...)
        end)
    end
end

-- Hooking FireServer manually (Xeno compatible attempt)
local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" then
        warn("FIRE SERVER: " .. self.Name)
        print("ARGS: ", ...)
    end
    return old(self, ...)
end)
