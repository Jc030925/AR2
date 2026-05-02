-- Simple Remote Logger by Gemini
print("--- REMOTE LOGGER ACTIVE ---")
print("Open your Console (Press F9) to see the remotes!")

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" then
        print("REMOTE FIRED: " .. self.FullName)
        warn("ARGS: ", unpack(args)) -- Lalabas na kulay yellow para madaling makita
    end
    return old(self, ...)
end)
setreadonly(mt, true)
