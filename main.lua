local Games = {
    [4777817887] = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/BladeBall.lua",
    [5166944221] = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/DeathBall.lua"
}

local Url = Games[game.GameId]

if not Url then
    warn("Unsupported game")
    return
end

local Source = game:HttpGet(Url)
local Function = loadstring(Source)

if not Function then
    warn("Failed to load script")
    return
end

Function()
