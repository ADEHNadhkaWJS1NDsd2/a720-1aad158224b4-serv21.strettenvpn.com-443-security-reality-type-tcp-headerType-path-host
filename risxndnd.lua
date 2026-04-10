repeat task.wait() until game:IsLoaded()
if not hookmetamethod then return end

pcall(function()
    if makefolder and not isfolder("PhantomSkinChanger") then makefolder("PhantomSkinChanger") end
end)

for i, v in getgc() do
    if typeof(v) == "function" and string.find(debug.info(v, "s"), "AnalyticsPipelineController") then
        hookfunction(v, function()
            return task.wait(9e9)
        end)
    end
end

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = gethui and gethui() or game:GetService("CoreGui")
local localPlayer = players.LocalPlayer
local Camera = workspace.CurrentCamera

for i, v in getgc() do
    if typeof(v) == "function" and string.find(debug.info(v, "s"), "AnalyticsPipelineController") then
        hookfunction(v, function()
            return task.wait(9e9)
        end)
    end
end

pcall(function()
    if getconnections then
        local logService = game:GetService("LogService")
        for _, conn in ipairs(getconnections(logService.MessageOut)) do
            pcall(function() conn:Disable() end)
        end
    end
end)

pcall(function()
    if getconnections then
        local scriptContext = game:GetService("ScriptContext")
        for _, conn in ipairs(getconnections(scriptContext.Error)) do
            pcall(function() conn:Disable() end)
        end
    end
end)

pcall(function()
    if setthreadidentity then setthreadidentity(8) end
end)

pcall(function()
    if sethiddenproperty then
        sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
    end
end)

pcall(function()
    if hookfunction then
        for i, v in getgc(true) do
            if typeof(v) == "function" then
                local info = debug.info(v, "s")
                if info and (string.find(info, "Analytics") or string.find(info, "Telemetry") or string.find(info, "Detection") or string.find(info, "AntiCheat") or string.find(info, "Integrity")) then
                    pcall(function()
                        hookfunction(v, function()
                            return task.wait(9e9)
                        end)
                    end)
                end
            end
        end
    end
end)

pcall(function()
    if getconnections then
        local remotes = replicatedStorage:FindFirstChild("Remotes")
        if remotes then
            for _, desc in ipairs(remotes:GetDescendants()) do
                if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                    local n = string.lower(desc.Name)
                    if string.find(n, "analytics") or string.find(n, "report") or string.find(n, "ban") or string.find(n, "kick") or string.find(n, "detect") or string.find(n, "log") or string.find(n, "telemetry") or string.find(n, "anticheat") then
                        pcall(function()
                            for _, conn in ipairs(getconnections(desc.OnClientEvent)) do
                                pcall(function() conn:Disable() end)
                            end
                        end)
                        pcall(function()
                            if desc:IsA("RemoteEvent") then
                                desc.OnClientEvent:Connect(function() return end)
                            end
                        end)
                    end
                end
            end
        end
    end
end)

pcall(function()
    if getrawmetatable and setreadonly then
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        local oldNewindex = mt.__newindex
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            if type(key) == "string" then
                local lower = string.lower(key)
                if lower == "anticheat" or lower == "detection" or lower == "securitycheck" or lower == "integrity" then
                    return nil
                end
            end
            return oldIndex(self, key)
        end)
        setreadonly(mt, true)
    end
end)

pcall(function()
    if getactors and run_on_actor then
        local actors = {}
        pcall(function() actors = getactors() end)
        for _, actor in ipairs(actors) do
            pcall(function()
                run_on_actor(actor, [[
                    if not hookmetamethod then return end
                    pcall(function()
                        for i, v in getgc() do
                            if typeof(v) == "function" and string.find(debug.info(v, "s"), "AnalyticsPipelineController") then
                                hookfunction(v, function()
                                    return task.wait(9e9)
                                end)
                            end
                        end
                    end)
                    pcall(function()
                        for i, v in getgc(true) do
                            if typeof(v) == "function" then
                                local info = debug.info(v, "s")
                                if info and (string.find(info, "Analytics") or string.find(info, "Telemetry") or string.find(info, "Detection") or string.find(info, "AntiCheat") or string.find(info, "Integrity")) then
                                    pcall(function()
                                        hookfunction(v, function()
                                            return task.wait(9e9)
                                        end)
                                    end)
                                end
                            end
                        end
                    end)
                    pcall(function()
                        local blocked = {EquipCosmetic=1,FavoriteCosmetic=1,Analytics=1,Log=1,Report=1,Ban=1,Kick=1,Detect=1,Exploit=1,Cheat=1,Inject=1,Hook=1,Telemetry=1,AntiCheat=1,Integrity=1}
                        local oldNC
                        oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                            local ok, method = pcall(getnamecallmethod)
                            if not ok then return oldNC(self, ...) end
                            if method == "FireServer" or method == "InvokeServer" then
                                local n = tostring(self)
                                for k in pairs(blocked) do
                                    if string.find(n, k) then return end
                                end
                            end
                            return oldNC(self, ...)
                        end)
                    end)
                ]])
            end)
        end
    end
end)

pcall(function()
    if hookfunction then
        local oldHttpGet = game.HttpGet
        hookfunction(oldHttpGet, function(self, url, ...)
            if type(url) == "string" then
                local lower = string.lower(url)
                if string.find(lower, "analytics") or string.find(lower, "telemetry") or string.find(lower, "report") or string.find(lower, "detect") then
                    return "{}"
                end
            end
            return oldHttpGet(self, url, ...)
        end)
    end
end)

local blockedMethods = {
    FireServer = {"EquipCosmetic","FavoriteCosmetic","Analytics","Log","Report","Ban","Kick","Detect","Exploit","Cheat","Inject","Hook","Telemetry","AntiCheat","Integrity"},
    InvokeServer = {"Analytics","Log","Report","Ban","Kick","Detect","Exploit","Telemetry","AntiCheat","Integrity"},
    FireAllClients = {},
    FireClient = {}
}

local function isBlocked(method, name)
    local list = blockedMethods[method]
    if not list then return false end
    for _, k in ipairs(list) do
        if string.find(name, k) then return true end
    end
    return false
end

local function waitForCharacter()
    if not localPlayer.Character then localPlayer.CharacterAdded:Wait() end
    task.wait(2)
end
waitForCharacter()

local playerScripts
local attempts = 0
repeat
    task.wait(1)
    playerScripts = localPlayer:FindFirstChild("PlayerScripts")
    attempts = attempts + 1
    if attempts > 20 then return end
until playerScripts

local controllers
attempts = 0
repeat
    task.wait(1)
    controllers = playerScripts:FindFirstChild("Controllers")
    attempts = attempts + 1
    if attempts > 20 then return end
until controllers

local modules
attempts = 0
repeat
    task.wait(1)
    modules = replicatedStorage:FindFirstChild("Modules")
    attempts = attempts + 1
    if attempts > 20 then return end
until modules

local function waitForModule(parent, name, timeout)
    local timeElapsed = 0
    while not parent:FindFirstChild(name) and timeElapsed < timeout do
        task.wait(0.5)
        timeElapsed = timeElapsed + 0.5
    end
    return parent:FindFirstChild(name)
end

local cosmeticLib = waitForModule(modules, "CosmeticLibrary", 10)
local itemLib = waitForModule(modules, "ItemLibrary", 10)
local dataCtrl = waitForModule(controllers, "PlayerDataController", 10)
local dataUtility = waitForModule(modules, "PlayerDataUtility", 10)
if not cosmeticLib or not itemLib or not dataCtrl then return end

local EnumLibrary, CosmeticLibrary, ItemLibrary, DataController, DataUtility
local loadSuccess = pcall(function()
    CosmeticLibrary = require(cosmeticLib)
    ItemLibrary = require(itemLib)
    DataController = require(dataCtrl)
    DataUtility = require(dataUtility)
    local enumLib = modules:FindFirstChild("EnumLibrary")
    if enumLib then
        EnumLibrary = require(enumLib)
        if EnumLibrary and EnumLibrary.WaitForEnumBuilder then
            task.spawn(function() pcall(function() EnumLibrary:WaitForEnumBuilder() end) end)
        end
    end
end)

if not loadSuccess or not CosmeticLibrary or not ItemLibrary or not DataController then return end

local function GetAllWeaponMapsTo(bool)
    local weapons = {}
    if ItemLibrary and ItemLibrary.Items then
        for name in pairs(ItemLibrary.Items) do
            if type(name) == "string" and not string.find(name, "MISSING_") then
                weapons[name] = bool
            end
        end
    end
    return weapons
end

DataController.OwnsAllWeapons = function() return true end
DataController.GetUnlockedWeapons = function() return GetAllWeaponMapsTo(true) end

local equipped = {}
local favorites = {}
local constructingWeapon, viewingProfile, lastUsedWeapon
local DynamicLists = { Wrap = {}, Charm = {}, Finisher = {} }

task.spawn(function()
    local function addToList(list, name)
        if type(name) == "string" and not table.find(DynamicLists[list], name) then
            table.insert(DynamicLists[list], name)
        end
    end
    if CosmeticLibrary and CosmeticLibrary.Cosmetics then
        for cName, cData in pairs(CosmeticLibrary.Cosmetics) do
            local t = cData.Type
            if t == "Wrap" then addToList("Wrap", cName)
            elseif t == "Charm" then addToList("Charm", cName)
            elseif t == "Finisher" or t == "KillEffect" then addToList("Finisher", cName)
            end
        end
    end
    if ItemLibrary and ItemLibrary.Items then
        for cName, cData in pairs(ItemLibrary.Items) do
            local t = cData.Type
            if t == "Wrap" then addToList("Wrap", cName)
            elseif t == "Charm" then addToList("Charm", cName)
            elseif t == "Finisher" or t == "KillEffect" then addToList("Finisher", cName)
            end
        end
    end
end)

local assetsFolder = playerScripts:WaitForChild("Assets", 5)
local viewModelsFolder = assetsFolder and assetsFolder:FindFirstChild("ViewModels")
local weaponsFolder = viewModelsFolder and viewModelsFolder:FindFirstChild("Weapons")
local charmsFolder = assetsFolder and assetsFolder:FindFirstChild("Charms")
local wrapTexturesFolder = assetsFolder and assetsFolder:FindFirstChild("WrapTextures")
local AssetIndex = {}

local function safeFind(parent, target)
    if not parent then return nil end
    local f = parent:FindFirstChild(target)
    if f then return f end
    for _, c in ipairs(parent:GetChildren()) do
        if c:IsA("Folder") or c:IsA("Model") then
            local sub = c:FindFirstChild(target)
            if sub then return sub end
        end
    end
    return nil
end

local function GetAsset(name, assetType)
    if type(name) ~= "string" or name == "" then return nil end
    local cacheKey = name .. "_" .. tostring(assetType)
    if AssetIndex[cacheKey] ~= nil then
        return AssetIndex[cacheKey] == false and nil or AssetIndex[cacheKey]
    end
    local found = nil
    local cleanName = string.lower(string.gsub(name, "[%s%p]", ""))
    pcall(function()
        if assetType == "Weapon" and weaponsFolder then
            found = safeFind(weaponsFolder, name)
        elseif assetType == "Skin" and viewModelsFolder then
            for _, child in ipairs(viewModelsFolder:GetChildren()) do
                if child.Name ~= "Weapons" and (child:IsA("Folder") or child:IsA("Model")) then
                    if string.lower(string.gsub(child.Name, "[%s%p]", "")) == cleanName then found = child break end
                    local subFound = child:FindFirstChild(name)
                    if subFound then found = subFound break end
                end
            end
        elseif assetType == "Charm" and charmsFolder then
            found = safeFind(charmsFolder, name)
            if not found then
                for _, c in ipairs(charmsFolder:GetDescendants()) do
                    if (c:IsA("Model") or c:IsA("Folder") or c:IsA("BasePart")) and string.lower(string.gsub(c.Name, "[%s%p]", "")) == cleanName then
                        found = c break
                    end
                end
            end
        elseif assetType == "Wrap" and wrapTexturesFolder then
            found = safeFind(wrapTexturesFolder, name)
            if not found then
                for _, c in ipairs(wrapTexturesFolder:GetChildren()) do
                    local cClean = string.lower(string.gsub(c.Name, "[%s%p]", ""))
                    if cClean == cleanName or string.find(cClean, cleanName) or string.find(cleanName, cClean) then
                        found = c break
                    end
                end
            end
        end
    end)
    AssetIndex[cacheKey] = found or false
    return found
end

local function cloneCosmetic(name, cosmeticType, options)
    if not CosmeticLibrary or not CosmeticLibrary.Cosmetics then return nil end
    local base = CosmeticLibrary.Cosmetics[name]
    if not base then return nil end
    local data = {}
    for k, v in pairs(base) do data[k] = v end
    data.Name = name
    data.Type = data.Type or cosmeticType
    data.Seed = math.random(1, 1000000)
    if EnumLibrary then
        pcall(function()
            local enumId = EnumLibrary:ToEnum(name)
            if enumId then data.Enum, data.ObjectID = enumId, enumId end
        end)
    end
    if options then
        if options.inverted then data.Inverted = true end
        if options.favoritesOnly then data.OnlyUseFavorites = true end
    end
    return data
end

CosmeticLibrary.OwnsCosmeticNormally = function() return true end
CosmeticLibrary.OwnsCosmeticUniversally = function() return true end
CosmeticLibrary.OwnsCosmeticForSomething = function() return true end
CosmeticLibrary.OwnsCosmeticForWeapon = function() return true end
CosmeticLibrary.HasNotification = function() return false end
local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
    if type(name) == "string" and string.find(name, "MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
    return true
end

local originalGet = DataController.Get
DataController.Get = function(self, key)
    local data = originalGet(self, key)
    if key == "CosmeticInventory" then return setmetatable({}, {__index = function() return true end}) end
    if key == "FavoritedCosmetics" then
        local result = {}
        if type(data) == "table" then for k, v in pairs(data) do result[k] = v end end
        for weapon, favs in pairs(favorites) do
            result[weapon] = result[weapon] or {}
            for name, isFav in pairs(favs) do result[weapon][name] = isFav end
        end
        return result
    end
    return data
end

local originalGetWeaponData = DataController.GetWeaponData
DataController.GetWeaponData = function(self, weaponName)
    local originalData = originalGetWeaponData(self, weaponName)
    local data = {}
    if type(originalData) == "table" then for k, v in pairs(originalData) do data[k] = v end end
    data.Unlocked = true
    data.Level = 100
    data.XP = 999999
    if equipped and equipped[weaponName] then
        for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do
            data[cosmeticType] = cosmeticData
        end
    end
    return data
end

local FighterController
task.spawn(function()
    local fc = controllers and controllers:FindFirstChild("FighterController")
    if fc then pcall(function() FighterController = require(fc) end) end
end)

local replicateDebounce = false
local function debouncedReplicate()
    if replicateDebounce then return end
    replicateDebounce = true
    task.delay(0.25, function()
        pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
        replicateDebounce = false
    end)
end

task.spawn(function()
    task.wait(1)
    local remotes = replicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end
    local dataRemotes = remotes:FindFirstChild("Data")
    local replicationRemotes = remotes:FindFirstChild("Replication")
    local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
    local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
    local fighterRemotes = replicationRemotes and replicationRemotes:FindFirstChild("Fighter")
    local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")
    if not equipRemote then return end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local ok, method = pcall(getnamecallmethod)
        if not ok then return oldNamecall(self, ...) end

        if method == "FireServer" or method == "InvokeServer" then
            local selfStr = tostring(self)
            if isBlocked(method, selfStr) then return end
        end

        if method ~= "FireServer" then return oldNamecall(self, ...) end

        if useItemRemote and self == useItemRemote and FighterController then
            local usedObjId = select(1, ...)
            task.spawn(function()
                pcall(function()
                    local fighter = FighterController:GetFighter(localPlayer)
                    if fighter and type(fighter.Items) == "table" then
                        for _, item in pairs(fighter.Items) do
                            pcall(function()
                                if type(item) == "table" then
                                    if type(item.Get) == "function" then
                                        if item:Get("ObjectID") == usedObjId then lastUsedWeapon = item.Name end
                                    elseif item.ObjectID == usedObjId then
                                        lastUsedWeapon = item.Name
                                    end
                                end
                            end)
                        end
                    end
                end)
            end)
        end

        if self == equipRemote then
            local args = {...}
            local weaponName, cosmeticType, cosmeticName = args[1], args[2], args[3]
            local options = args[4] or {}
            equipped[weaponName] = equipped[weaponName] or {}
            if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                equipped[weaponName][cosmeticType] = nil
                if not next(equipped[weaponName]) then equipped[weaponName] = nil end
            else
                local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                if cloned then equipped[weaponName][cosmeticType] = cloned end
            end
            debouncedReplicate()
            return
        end

        if favoriteRemote and self == favoriteRemote then
            local args = {...}
            favorites[args[1]] = favorites[args[1]] or {}
            favorites[args[1]][args[2]] = args[3] or nil
            return
        end

        return oldNamecall(self, ...)
    end)
end)

if ItemLibrary then
    local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
    ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
        if not weaponData then return originalGetViewModelImage(self, weaponData, highRes) end
        local weaponName = weaponData.Name
        if viewingProfile == localPlayer and equipped[weaponName] and equipped[weaponName].Skin then
            local skinInfo = self.ViewModels[equipped[weaponName].Skin.Name]
            if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
        end
        return originalGetViewModelImage(self, weaponData, highRes)
    end
end

task.spawn(function()
    task.wait(3)
    pcall(function()
        local clientItemPath = playerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem
        local ClientItem = require(clientItemPath)
        if ClientItem._CreateViewModel then
            local orig = ClientItem._CreateViewModel
            ClientItem._CreateViewModel = function(self, viewmodelRef)
                local weaponName = self.Name
                local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                constructingWeapon = (weaponPlayer == localPlayer) and weaponName or nil
                if weaponPlayer == localPlayer then lastUsedWeapon = weaponName end
                if weaponPlayer == localPlayer and equipped[weaponName] and equipped[weaponName].Skin and viewmodelRef then
                    pcall(function()
                        local dataKey = self:ToEnum("Data")
                        local skinKey = self:ToEnum("Skin")
                        local nameKey = self:ToEnum("Name")
                        if viewmodelRef[dataKey] then
                            viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                            viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
                        elseif viewmodelRef.Data then
                            viewmodelRef.Data.Skin = equipped[weaponName].Skin
                            viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
                        end
                    end)
                end
                local result = orig(self, viewmodelRef)
                constructingWeapon = nil
                return result
            end
        end
    end)

    pcall(function()
        local viewModelModule = playerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
        if viewModelModule then
            local ClientViewModel = require(viewModelModule)
            if ClientViewModel.GetWrap then
                local orig = ClientViewModel.GetWrap
                ClientViewModel.GetWrap = function(self)
                    local weaponName = self.ClientItem and self.ClientItem.Name
                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                    if weaponName and weaponPlayer == localPlayer and equipped[weaponName] and equipped[weaponName].Wrap then
                        return equipped[weaponName].Wrap
                    end
                    return orig(self)
                end
            end
            local origNew = ClientViewModel.new
            ClientViewModel.new = function(replicatedData, clientItem)
                local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                local weaponName = constructingWeapon or clientItem.Name
                if weaponPlayer == localPlayer and equipped[weaponName] then
                    pcall(function()
                        local ReplicatedClass = require(replicatedStorage.Modules.ReplicatedClass)
                        local dataKey = ReplicatedClass:ToEnum("Data")
                        replicatedData[dataKey] = replicatedData[dataKey] or {}
                        local cosmetics = equipped[weaponName]
                        if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                        if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                        if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
                    end)
                end
                local result = origNew(replicatedData, clientItem)
                if weaponPlayer == localPlayer and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
                    task.spawn(function()
                        pcall(function() result:_UpdateWrap() end)
                        task.wait(0.1)
                        pcall(function() if not result._destroyed then result:_UpdateWrap() end end)
                    end)
                end
                return result
            end
        end
    end)

    pcall(function()
        local ViewProfile = require(playerScripts.Modules.Pages.ViewProfile)
        if ViewProfile and ViewProfile.Fetch then
            local orig = ViewProfile.Fetch
            ViewProfile.Fetch = function(self, targetPlayer)
                viewingProfile = targetPlayer
                return orig(self, targetPlayer)
            end
        end
    end)

    pcall(function()
        local ClientEntity = require(playerScripts.Modules.ClientReplicatedClasses.ClientEntity)
        if ClientEntity.ReplicateFromServer then
            local orig = ClientEntity.ReplicateFromServer
            ClientEntity.ReplicateFromServer = function(self, action, ...)
                if action == "FinisherEffect" then
                    local args = {...}
                    local killerName = args[3]
                    local decodedKiller = killerName
                    if type(killerName) == "userdata" and EnumLibrary and EnumLibrary.FromEnum then
                        pcall(function() decodedKiller = EnumLibrary:FromEnum(killerName) end)
                    end
                    local isOurKill = tostring(decodedKiller) == localPlayer.Name or string.lower(tostring(decodedKiller)) == string.lower(localPlayer.Name)
                    if isOurKill and lastUsedWeapon and equipped[lastUsedWeapon] and equipped[lastUsedWeapon].Finisher then
                        local finisherData = equipped[lastUsedWeapon].Finisher
                        local finisherEnum = finisherData.Enum
                        if not finisherEnum and EnumLibrary then
                            pcall(function() finisherEnum = EnumLibrary:ToEnum(finisherData.Name) end)
                        end
                        if finisherEnum then
                            args[1] = finisherEnum
                            return orig(self, action, unpack(args))
                        end
                    end
                end
                return orig(self, action, ...)
            end
        end
    end)
end)

local weaponSkins = {
    ["Assault Rifle"] = {"AK-47","AUG","Boneclaw Rifle","AKEY-47","Gingerbread AUG","Phoenix Rifle","Tommy Gun","10B Visits","Glorious Assault Rifle"},
    ["Battle Axe"] = {"The Shred","Nordic Axe","Ban Axe","Cerulean Axe","Glorious Battle Axe","Mimic Axe","Keyttle Axe","Balloon Axe"},
    ["Bow"] = {"Compound Bow","Raven Bow","Bat Bow","Frostbite Bow","Dream Bow","Key Bow","Glorious Bow","Balloon Bow","Beloved Bow"},
    ["Burst Rifle"] = {"Aqua Burst","Electro Rifle","Pixel Burst","Spectral Burst","Pine Burst","FAMAS","Glorious Burst Rifle","Keyst Rifle"},
    ["Chainsaw"] = {"Blobsaw","Handsaws","Buzzsaw","Festive Buzzsaw","Mega Drill","Glorious Chainsaw"},
    ["Crossbow"] = {"Pixel Crossbow","Frostbite Crossbow","Harpoon Crossbow","Violin Crossbow","Glorious Crossbow","Crossbone","Arch Crossbow"},
    ["Daggers"] = {"Aces","Cookies","Crystal Daggers","Paper Planes","Shurikens","Glorious Daggers","Bat Daggers","Keynais","Broken Hearts"},
    ["Distortion"] = {"Glorious Distortion","Electropunk Distortion","Experiment D15","Plasma Distortion","Magma Distortion","Cyber Distortion","Sleighstortion"},
    ["Energy Pistols"] = {"Hacker Pistols","Apex Pistols","New Year Energy Pistols","Void Pistols","Hydro Pistols","Glorious Energy Pistols","Soul Pistols","Hyperlaser Guns"},
    ["Energy Rifle"] = {"Hacker Rifle","Apex Rifle","New Year Energy Rifle","Hydro Rifle","Void Rifle","Glorious Energy Rifle","Soul Rifle"},
    ["Exogun"] = {"Singularity","Wondergun","Ray Gun","Exogourd","Midnight Festive Exogun","Repulsor","Glorious Exogun"},
    ["Fists"] = {"Boxing Gloves","Brass Knuckles","Pumpkin Claws","Festive Fists","Fists of Hurt","Glorious Fists","Fist"},
    ["Flamethrower"] = {"Lamethrower","Pixel Flamethrower","Jack O'Thrower","Snowblower","Glitterthrower","Glorious Flamethrower","Keythrower","Rainbowthrower"},
    ["Flare Gun"] = {"Dynamite Gun","Firework Gun","Vexed Flare Gun","Wrapped Flare Gun","Banana Flare","Glorious Flare Gun"},
    ["Flashbang"] = {"Disco Ball","Camera","Pixel Flashbang","Skullbang","Shining Star","Lightbulb","Glorious Flashbang"},
    ["Freeze Ray"] = {"Bubble Ray","Temporal Ray","Spider Ray","Wrapped Freeze Ray","Gum Ray","Glorious Freeze Ray"},
    ["Grenade"] = {"Water Balloon","Whoopee Cushion","Soul Grenade","Jingle Grenade","Dynamite","Keynade","Glorious Grenade","Frozen Grenade","Cuddle Bomb"},
    ["Grenade Launcher"] = {"Swashbuckler","Uranium Launcher","Skull Launcher","Snowball Launcher","Gearnade Launcher","Glorious Grenade Launcher","Balloon Launcher"},
    ["Gunblade"] = {"Hyper Gunblade","Elf's Gunblade","Crude Gunblade","Gunsaw","Glorious Gunblade","Boneblade"},
    ["Handgun"] = {"Blaster","Hand Gun","Pixel Handgun","Pumpkin Handgun","Gingerbread Handgun","Gumball Handgun","Stealth Handgun","Glorious Handgun","Warp Handgun","Towerstone Handgun"},
    ["Jump Pad"] = {"Trampoline","Bounce House","Shady Chicken Sandwich","Glorious Jump Pad","Spider Web","Jolly Man"},
    ["Katana"] = {"Lightning Bolt","Saber","Pixel Katana","Evil Trident","New Year Katana","Keytana","Stellar Katana","Glorious Katana","Arch Katana","Crystal Katana","Linked Sword"},
    ["Knife"] = {"Karambit","Chancla","Machete","Candy Cane","Balisong","Armature.001","Glorious Knife","Keyrambit","Keylisong","Caladbolg"},
    ["Maul"] = {"Sleigh Maul","Ice Maul","Glorious Maul","Ban Hammer"},
    ["Medkit"] = {"Briefcase","Sandwich","Laptop","Bucket of Candy","Milk & Cookies","Medkitty","Glorious Medkit","Box of Chocolates"},
    ["Minigun"] = {"Lasergun 3000","Pixel Minigun","Pumpkin Minigun","Wrapped Minigun","Fighter Jet","Glorious Minigun"},
    ["Molotov"] = {"Coffee","Torch","Vexed Candle","Hot Coals","Lava Lamp","Glorious Molotov","Arch Molotov"},
    ["Paintball Gun"] = {"Boba Gun","Slime Gun","Brain Gun","Snowball Gun","Ketchup Gun","Glorious Paintball Gun","Paintballoon Gun"},
    ["Permafrost"] = {"Snowman Permafrost","Ice Permafrost","Glorious Permafrost"},
    ["RPG"] = {"Nuke Launcher","RPKEY","Spaceship Launcher","Pumpkin Launcher","Firework Launcher","Squid Launcher","Pencil Launcher","Glorious RPG","Rocket Launcher"},
    ["Revolver"] = {"Sheriff","Desert Eagle","Boneclaw Revolver","Peppermint Sheriff","Keyvolver","Peppergun","Glorious Revolver"},
    ["Riot Shield"] = {"Door","Sled","Energy Shield","Masterpiece","Glorious Riot Shield","Tombstone Shield"},
    ["Satchel"] = {"Advanced Satchel","Suspicious Gift","Notebook Satchel","Bag o' Money","Glorious Satchel","Potion Satchel"},
    ["Scythe"] = {"Scythe of Death","Anchor","Keythe","Bat Scythe","Cryo Scythe","Bug Net","Sakura Scythe","Glorious Scythe","Crystal Scythe"},
    ["Shorty"] = {"Not So Shorty","Too Shorty","Lovely Shorty","Demon Shorty","Wrapped Shorty","Balloon Shorty","Glorious Shorty"},
    ["Shotgun"] = {"Balloon Shotgun","Hyper Shotgun","Broomstick","Wrapped Shotgun","Cactus Shotgun","Shotkey","Glorious Shotgun"},
    ["Slingshot"] = {"Goalpost","Stick","Boneshot","Reindeer Slingshot","Harp","Glorious Slingshot","Lucky Horseshoe"},
    ["Smoke Grenade"] = {"Emoji Cloud","Balance","Eyeball","Snowglobe","Hourglass","Glorious Smoke Grenade"},
    ["Spray"] = {"Lovely Spray","Pine Spray","Nail Gun","Spray Bottle","Glorious Spray","Boneclaw Spray","Key Spray"},
    ["Subspace Tripmine"] = {"Don't Press","Spring","Trick or Treat","Dev-in-the-Box","DIY Tripmine","Glorious Subspace Tripmine","Pot o' Keys"},
    ["Trowel"] = {"Plastic Shovel","Garden Shovel","Pumpkin Carver","Snow Shovel","Paintbrush","Glorious Trowel"},
    ["Uzi"] = {"Electro Uzi","Water Uzi","Demon Uzi","Pine Uzi","Money Gun","Keyzi","Glorious Uzi"},
    ["War Horn"] = {"Trumpet","Mammoth Horn","Megaphone","Air Horn","Glorious War Horn","Boneclaw Horn"},
    ["Warper"] = {"Glorious Warper","Electropunk Warper","Experiment W4","Glitter Warper","Arcane Warper","Hotel Bell","Frost Warper"},
    ["Warpstone"] = {"Glorious Warpstone","Unstable Warpstone","Warpeye","Warpbone","Cyber Warpstone","Teleport Disc","Electropunk Warpstone","Warpstar"}
}

local Categories = {
    Pistols = {"Energy Pistols","Handgun","Revolver","Flare Gun","Shorty","Uzi"},
    MidTier = {"Bow","Crossbow","Daggers","Fists","Jump Pad","Katana","Knife","Maul","Medkit","Molotov","Paintball Gun","Permafrost","Riot Shield","Satchel","Scythe","Shotgun","Slingshot","Smoke Grenade","Spray","Subspace Tripmine","Trowel","War Horn","Warper","Warpstone","Flashbang","Grenade","Gunblade","Battle Axe","Chainsaw"},
    Rifles = {"Assault Rifle","Burst Rifle","Energy Rifle","Exogun","Flamethrower","Freeze Ray","Grenade Launcher","Minigun","RPG","Distortion"}
}

local function SafeCloneModel(source, isIcon)
    if not source then return nil, 5 end
    local oldArchivable = source.Archivable
    source.Archivable = true
    local clone = source:Clone()
    source.Archivable = oldArchivable
    if not clone then return nil, 5 end
    local parts = {}
    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = true
            desc.CanCollide = false
            desc.CastShadow = false
            table.insert(parts, desc)
        elseif desc:IsA("Script") or desc:IsA("LocalScript") then
            pcall(function() desc:Destroy() end)
        end
    end
    local mdl = clone
    if not mdl:IsA("Model") then
        mdl = Instance.new("Model")
        mdl.Name = clone.Name
        clone.Parent = mdl
    end
    if #parts == 0 then
        local dummy = Instance.new("Part")
        dummy.Size = Vector3.new(1,1,1)
        dummy.Transparency = 1
        dummy.Anchored = true
        dummy.CanCollide = false
        dummy.Parent = mdl
        table.insert(parts, dummy)
    end
    local cf, size = mdl:GetBoundingBox()
    local centerPart = Instance.new("Part")
    centerPart.Name = "ViewportCenter"
    centerPart.Transparency = 1
    centerPart.CanCollide = false
    centerPart.Anchored = true
    centerPart.Size = Vector3.new(0.01,0.01,0.01)
    centerPart.CFrame = cf
    centerPart.Parent = mdl
    mdl.PrimaryPart = centerPart
    mdl:PivotTo(CFrame.new(0,0,0))
    local maxDim = math.max(size.X, size.Y, size.Z)
    if maxDim <= 0.1 then maxDim = 5 end
    if isIcon then
        for _, desc in ipairs(mdl:GetDescendants()) do
            if desc:IsA("Animation") or desc:IsA("Animator") or desc:IsA("Humanoid") or desc:IsA("AnimationController") then
                pcall(function() desc:Destroy() end)
            end
        end
    end
    return mdl, maxDim
end

local function ApplyWrapToModel(mdl, wrapName)
    local mainGroup = nil
    local texFolderNames = {wrapName}
    if CosmeticLibrary and CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[wrapName] then
        local cData = CosmeticLibrary.Cosmetics[wrapName]
        if type(cData.WrapGroups) == "table" then
            mainGroup = cData.WrapGroups[1]
            for _, grp in ipairs(cData.WrapGroups) do
                if grp.Textures and type(grp.Textures) == "string" and grp.Textures ~= "" then table.insert(texFolderNames, grp.Textures) end
                if grp.MaterialVariant and type(grp.MaterialVariant) == "string" and grp.MaterialVariant ~= "" then table.insert(texFolderNames, grp.MaterialVariant) end
            end
        end
    end
    local texturesToApply = {}
    local foundTexFolders = {}
    for _, tName in ipairs(texFolderNames) do
        if not foundTexFolders[tName] then
            local tFold = GetAsset(tName, "Wrap")
            if tFold then
                foundTexFolders[tName] = true
                for _, t in ipairs(tFold:GetDescendants()) do
                    if t:IsA("Texture") or t:IsA("Decal") or t:IsA("SurfaceAppearance") then
                        table.insert(texturesToApply, t)
                    end
                end
            end
        end
    end
    for _, p in ipairs(mdl:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 1 then
            local n = string.lower(p.Name)
            if not string.find(n,"hitbox") and not string.find(n,"collider") and not string.find(n,"arm") then
                if mainGroup then
                    if mainGroup.Color and mainGroup.Color ~= Color3.new(163/255,162/255,165/255) then p.Color = mainGroup.Color end
                    if mainGroup.Material then pcall(function() p.Material = mainGroup.Material end) end
                    if mainGroup.MaterialVariant and mainGroup.MaterialVariant ~= "" then pcall(function() p.MaterialVariant = mainGroup.MaterialVariant end) end
                    if mainGroup.Transparency then p.Transparency = mainGroup.Transparency end
                    if mainGroup.Reflectance then p.Reflectance = mainGroup.Reflectance end
                end
                for _, old in ipairs(p:GetChildren()) do
                    if old:IsA("SurfaceAppearance") or old:IsA("Texture") or old:IsA("Decal") then old:Destroy() end
                end
                local hasSA = false
                for _, tex in ipairs(texturesToApply) do
                    if tex:IsA("SurfaceAppearance") then
                        if not hasSA and p:IsA("MeshPart") then tex:Clone().Parent = p hasSA = true end
                    else
                        tex:Clone().Parent = p
                    end
                end
            end
        end
    end
end

local function PlayIdleAnimation(mdl)
    if not mdl then return end
    local anim = mdl:FindFirstChildWhichIsA("Animation", true)
    if not anim then return end
    local animCtrl = mdl:FindFirstChildWhichIsA("AnimationController", true) or mdl:FindFirstChildWhichIsA("Humanoid", true)
    if not animCtrl then
        animCtrl = Instance.new("AnimationController")
        animCtrl.Parent = mdl
    end
    local animator = animCtrl:FindFirstChildWhichIsA("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = animCtrl
    end
    task.spawn(function()
        pcall(function()
            local track = animator:LoadAnimation(anim)
            track.Looped = true
            track:Play()
        end)
    end)
end

local function applyCosmeticLogic(weapon, cosmeticName, cosmeticType)
    local cloned = cloneCosmetic(cosmeticName, cosmeticType)
    equipped[weapon] = equipped[weapon] or {}
    equipped[weapon][cosmeticType] = cloned
    debouncedReplicate()
end

local accentColorElements = {}

local Theme = {
    MainBg = Color3.fromRGB(11,13,18),
    SectionBg = Color3.fromRGB(15,18,24),
    ItemBg = Color3.fromRGB(18,22,28),
    ItemHover = Color3.fromRGB(26,30,38),
    Accent = Color3.fromRGB(255,45,55),
    TextPrimary = Color3.fromRGB(245,245,255),
    TextSecondary = Color3.fromRGB(140,145,160),
    Border = Color3.fromRGB(35,40,50),
    BorderGlow = Color3.fromRGB(70,75,90),
    Background = Color3.fromRGB(11,13,18)
}

local function updateAccentColor(newColor)
    Theme.Accent = newColor
    for _, elem in ipairs(accentColorElements) do
        pcall(function()
            if elem.type == "BackgroundColor3" then elem.obj.BackgroundColor3 = newColor
            elseif elem.type == "Color" then elem.obj.Color = newColor
            elseif elem.type == "ImageColor3" then elem.obj.ImageColor3 = newColor
            elseif elem.type == "gradient" then
                elem.obj.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.MainBg),
                    ColorSequenceKeypoint.new(0.1, newColor),
                    ColorSequenceKeypoint.new(0.5, newColor),
                    ColorSequenceKeypoint.new(0.9, newColor),
                    ColorSequenceKeypoint.new(1, Theme.MainBg)
                })
            end
        end)
    end
end

local autoLoadEnabled = false
local autoSaveEnabled = false

local function serializeEquipped()
    local result = {}
    for weapon, cosmetics in pairs(equipped) do
        result[weapon] = {}
        for cosType, cosData in pairs(cosmetics) do
            if type(cosData) == "table" and cosData.Name then
                result[weapon][cosType] = cosData.Name
            end
        end
    end
    return result
end

local currentConfigName = ""

local function getConfigList()
    local list = {}
    pcall(function()
        if listfiles then
            local files = listfiles("PhantomSkinChanger")
            for _, f in ipairs(files) do
                local name = string.match(f, "([^/\$+)%.json$")
                if name and name ~= "_settings" then table.insert(list, name) end
            end
        end
    end)
    return list
end

local function saveSettings()
    pcall(function()
        if not isfolder("PhantomSkinChanger") then makefolder("PhantomSkinChanger") end
        local data = {
            autoLoad = autoLoadEnabled,
            autoSave = autoSaveEnabled,
            lastConfig = currentConfigName,
            accentColor = {r = math.floor(Theme.Accent.R * 255), g = math.floor(Theme.Accent.G * 255), b = math.floor(Theme.Accent.B * 255)}
        }
        writefile("PhantomSkinChanger/_settings.json", HttpService:JSONEncode(data))
    end)
end

local function loadSettings()
    pcall(function()
        if isfile("PhantomSkinChanger/_settings.json") then
            local raw = readfile("PhantomSkinChanger/_settings.json")
            local data = HttpService:JSONDecode(raw)
            if data.autoLoad ~= nil then autoLoadEnabled = data.autoLoad end
            if data.autoSave ~= nil then autoSaveEnabled = data.autoSave end
            if data.lastConfig then currentConfigName = data.lastConfig end
            if data.accentColor then
                updateAccentColor(Color3.fromRGB(data.accentColor.r or 255, data.accentColor.g or 45, data.accentColor.b or 55))
            end
        end
    end)
end

local function saveConfig(name)
    if not name or name == "" then return false end
    local ok = false
    pcall(function()
        if not isfolder("PhantomSkinChanger") then makefolder("PhantomSkinChanger") end
        local data = {
            accentColor = {r = math.floor(Theme.Accent.R * 255), g = math.floor(Theme.Accent.G * 255), b = math.floor(Theme.Accent.B * 255)},
            equipped = serializeEquipped()
        }
        writefile("PhantomSkinChanger/" .. name .. ".json", HttpService:JSONEncode(data))
        ok = true
    end)
    return ok
end

local function loadConfig(name)
    if not name or name == "" then return false end
    local success = false
    pcall(function()
        if isfile("PhantomSkinChanger/" .. name .. ".json") then
            local raw = readfile("PhantomSkinChanger/" .. name .. ".json")
            local data = HttpService:JSONDecode(raw)
            if data.accentColor then
                updateAccentColor(Color3.fromRGB(data.accentColor.r or 255, data.accentColor.g or 45, data.accentColor.b or 55))
            end
            if data.equipped then
                equipped = {}
                for weapon, cosmetics in pairs(data.equipped) do
                    for cosType, cosName in pairs(cosmetics) do
                        applyCosmeticLogic(weapon, cosName, cosType)
                    end
                end
            end
            success = true
        end
    end)
    return success
end

local function deleteConfig(name)
    if not name or name == "" then return false end
    pcall(function()
        if isfile("PhantomSkinChanger/" .. name .. ".json") then
            delfile("PhantomSkinChanger/" .. name .. ".json")
        end
    end)
    return true
end

local BASE_WIDTH = 1040
local BASE_HEIGHT = 720

local function getScale()
    local vp = Camera.ViewportSize
    local sx = vp.X / BASE_WIDTH
    local sy = vp.Y / BASE_HEIGHT
    return math.min(sx, sy, 1)
end

local guiName = "PhantomSkinChanger"
if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end
if CoreGui:FindFirstChild("PhantomMiniButton") then CoreGui["PhantomMiniButton"]:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = guiName
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
SG.IgnoreGuiInset = true
SG.Parent = CoreGui

local ScaleContainer = Instance.new("Frame")
ScaleContainer.Name = "ScaleContainer"
ScaleContainer.Size = UDim2.new(1,0,1,0)
ScaleContainer.BackgroundTransparency = 1
ScaleContainer.Parent = SG

local UIScale = Instance.new("UIScale")
UIScale.Scale = getScale()
UIScale.Parent = ScaleContainer

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    UIScale.Scale = getScale()
end)

local isMenuOpen = true
local onScreenPos = UDim2.new(0.5,-520,0.5,-360)
local offScreenPos = UDim2.new(0.5,-520,1.5,0)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0,1040,0,720)
MainFrame.Position = onScreenPos
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScaleContainer

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,6)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1,0,0,55)
TopBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 20
TopBar.Parent = MainFrame

local TopGrad = Instance.new("UIGradient")
TopGrad.Rotation = 90
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18,22,28)),
    ColorSequenceKeypoint.new(1, Theme.MainBg)
})
TopGrad.Parent = TopBar

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1,0,0,1)
TopLine.Position = UDim2.new(0,0,1,0)
TopLine.BackgroundColor3 = Theme.Border
TopLine.BorderSizePixel = 0
TopLine.ZIndex = 21
TopLine.Parent = TopBar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1,0,0,2)
AccentLine.Position = UDim2.new(0,0,0,0)
AccentLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 21
AccentLine.Parent = TopBar

local AccentGrad = Instance.new("UIGradient")
AccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.MainBg),
    ColorSequenceKeypoint.new(0.1, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent),
    ColorSequenceKeypoint.new(0.9, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.MainBg)
})
AccentGrad.Parent = AccentLine
table.insert(accentColorElements, {obj = AccentGrad, type = "gradient"})

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0,300,1,0)
Title.Position = UDim2.new(0,25,0,0)
Title.BackgroundTransparency = 1
Title.Text = "PHANTOM <font color='#8c91a0'>| LOADOUT</font>"
Title.RichText = true
Title.TextColor3 = Theme.TextPrimary
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 21
Title.Parent = TopBar

local SettingsBtn = Instance.new("ImageButton")
SettingsBtn.Size = UDim2.new(0,32,0,32)
SettingsBtn.Position = UDim2.new(1,-50,0.5,-16)
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Image = "rbxassetid://125856469259972"
SettingsBtn.ImageColor3 = Theme.TextSecondary
SettingsBtn.ZIndex = 22
SettingsBtn.Parent = TopBar

SettingsBtn.MouseEnter:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.TextPrimary}):Play()
end)
SettingsBtn.MouseLeave:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.TextSecondary}):Play()
end)

local dragging = false
local dragStart = nil
local startPos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        local sc = UIScale.Scale
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X / sc, startPos.Y.Scale, startPos.Y.Offset + delta.Y / sc)
        onScreenPos = MainFrame.Position
    end
end)

local settingsOpen = false

local SettingsPanel = Instance.new("Frame")
SettingsPanel.Name = "SettingsPanel"
SettingsPanel.Size = UDim2.new(1,0,1,-55)
SettingsPanel.Position = UDim2.new(0,0,0,-720)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(13,16,22)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.ZIndex = 15
SettingsPanel.ClipsDescendants = true
SettingsPanel.Parent = MainFrame

local SPStroke = Instance.new("UIStroke")
SPStroke.Color = Theme.Border
SPStroke.Thickness = 1
SPStroke.Parent = SettingsPanel

local SPBottomLine = Instance.new("Frame")
SPBottomLine.Size = UDim2.new(1,0,0,1)
SPBottomLine.Position = UDim2.new(0,0,1,-1)
SPBottomLine.BackgroundColor3 = Theme.Accent
SPBottomLine.BorderSizePixel = 0
SPBottomLine.ZIndex = 16
SPBottomLine.Parent = SettingsPanel
table.insert(accentColorElements, {obj = SPBottomLine, type = "BackgroundColor3"})

local SPTitle = Instance.new("TextLabel")
SPTitle.Size = UDim2.new(1,0,0,40)
SPTitle.Position = UDim2.new(0,25,0,10)
SPTitle.BackgroundTransparency = 1
SPTitle.Text = "SETTINGS"
SPTitle.TextColor3 = Theme.TextPrimary
SPTitle.Font = Enum.Font.GothamBold
SPTitle.TextSize = 16
SPTitle.TextXAlignment = Enum.TextXAlignment.Left
SPTitle.ZIndex = 16
SPTitle.Parent = SettingsPanel

local SPScroll = Instance.new("ScrollingFrame")
SPScroll.Size = UDim2.new(1,-20,1,-60)
SPScroll.Position = UDim2.new(0,10,0,55)
SPScroll.BackgroundTransparency = 1
SPScroll.BorderSizePixel = 0
SPScroll.ScrollBarThickness = 3
SPScroll.ScrollBarImageColor3 = Theme.BorderGlow
SPScroll.CanvasSize = UDim2.new(0,0,0,600)
SPScroll.ZIndex = 16
SPScroll.Parent = SettingsPanel

local SPLayout = Instance.new("UIListLayout")
SPLayout.FillDirection = Enum.FillDirection.Horizontal
SPLayout.SortOrder = Enum.SortOrder.LayoutOrder
SPLayout.Padding = UDim.new(0,16)
SPLayout.Parent = SPScroll

local SPPad = Instance.new("UIPadding")
SPPad.PaddingLeft = UDim.new(0,10)
SPPad.PaddingRight = UDim.new(0,10)
SPPad.PaddingTop = UDim.new(0,6)
SPPad.Parent = SPScroll

local LeftSection = Instance.new("Frame")
LeftSection.Size = UDim2.new(0.5,-12,0,540)
LeftSection.BackgroundColor3 = Color3.fromRGB(16,19,25)
LeftSection.BorderSizePixel = 0
LeftSection.ZIndex = 16
LeftSection.LayoutOrder = 1
LeftSection.Parent = SPScroll

local LSCorner = Instance.new("UICorner")
LSCorner.CornerRadius = UDim.new(0,6)
LSCorner.Parent = LeftSection

local LSStroke = Instance.new("UIStroke")
LSStroke.Color = Theme.Border
LSStroke.Thickness = 1
LSStroke.Parent = LeftSection

local LSTitle = Instance.new("TextLabel")
LSTitle.Size = UDim2.new(1,-20,0,36)
LSTitle.Position = UDim2.new(0,16,0,0)
LSTitle.BackgroundTransparency = 1
LSTitle.Text = "ACCENT COLOR"
LSTitle.TextColor3 = Theme.TextSecondary
LSTitle.Font = Enum.Font.GothamMedium
LSTitle.TextSize = 11
LSTitle.TextXAlignment = Enum.TextXAlignment.Left
LSTitle.ZIndex = 17
LSTitle.Parent = LeftSection

local ColorPreview = Instance.new("Frame")
ColorPreview.Size = UDim2.new(1,-32,0,36)
ColorPreview.Position = UDim2.new(0,16,0,38)
ColorPreview.BackgroundColor3 = Theme.Accent
ColorPreview.BorderSizePixel = 0
ColorPreview.ZIndex = 17
ColorPreview.Parent = LeftSection
table.insert(accentColorElements, {obj = ColorPreview, type = "BackgroundColor3"})

local CPCorner = Instance.new("UICorner")
CPCorner.CornerRadius = UDim.new(0,4)
CPCorner.Parent = ColorPreview

local CPLabel = Instance.new("TextLabel")
CPLabel.Size = UDim2.new(1,0,1,0)
CPLabel.BackgroundTransparency = 1
CPLabel.Text = "#FF2D37"
CPLabel.TextColor3 = Color3.fromRGB(255,255,255)
CPLabel.Font = Enum.Font.GothamBold
CPLabel.TextSize = 12
CPLabel.ZIndex = 18
CPLabel.Parent = ColorPreview

local pickerHue = 0
local pickerSat = 1
local pickerVal = 0.85

local function updatePickerColor()
    local c = Color3.fromHSV(pickerHue, pickerSat, pickerVal)
    updateAccentColor(c)
    ColorPreview.BackgroundColor3 = c
    local r = math.floor(c.R * 255)
    local g = math.floor(c.G * 255)
    local b = math.floor(c.B * 255)
    CPLabel.Text = string.format("#%02X%02X%02X", r, g, b)
end

local SV_SIZE = 200
local SVFrame = Instance.new("Frame")
SVFrame.Size = UDim2.new(0,SV_SIZE,0,SV_SIZE)
SVFrame.Position = UDim2.new(0,16,0,84)
SVFrame.BackgroundColor3 = Color3.fromHSV(pickerHue, 1, 1)
SVFrame.BorderSizePixel = 0
SVFrame.ZIndex = 17
SVFrame.ClipsDescendants = true
SVFrame.Parent = LeftSection

local SVCorner = Instance.new("UICorner")
SVCorner.CornerRadius = UDim.new(0,4)
SVCorner.Parent = SVFrame

local SVStroke = Instance.new("UIStroke")
SVStroke.Color = Theme.Border
SVStroke.Thickness = 1
SVStroke.Parent = SVFrame

local WhiteGrad = Instance.new("ImageLabel")
WhiteGrad.Size = UDim2.new(1,0,1,0)
WhiteGrad.BackgroundTransparency = 1
WhiteGrad.Image = "rbxassetid://4155801252"
WhiteGrad.ZIndex = 18
WhiteGrad.Parent = SVFrame

local BlackGrad = Instance.new("ImageLabel")
BlackGrad.Size = UDim2.new(1,0,1,0)
BlackGrad.BackgroundTransparency = 1
BlackGrad.Image = "rbxassetid://4155801252"
BlackGrad.ImageColor3 = Color3.new(0,0,0)
BlackGrad.Rotation = 270
BlackGrad.ZIndex = 19
BlackGrad.Parent = SVFrame

local SVCursor = Instance.new("Frame")
SVCursor.Size = UDim2.new(0,12,0,12)
SVCursor.AnchorPoint = Vector2.new(0.5,0.5)
SVCursor.Position = UDim2.new(pickerSat,0,1-pickerVal,0)
SVCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
SVCursor.BorderSizePixel = 0
SVCursor.ZIndex = 21
SVCursor.Parent = SVFrame

local SVCursorCorner = Instance.new("UICorner")
SVCursorCorner.CornerRadius = UDim.new(1,0)
SVCursorCorner.Parent = SVCursor

local SVCursorStroke = Instance.new("UIStroke")
SVCursorStroke.Color = Color3.fromRGB(0,0,0)
SVCursorStroke.Thickness = 2
SVCursorStroke.Parent = SVCursor

local HUE_W = 20
local HUE_H = SV_SIZE
local HueBar = Instance.new("Frame")
HueBar.Size = UDim2.new(0,HUE_W,0,HUE_H)
HueBar.Position = UDim2.new(0,16 + SV_SIZE + 12,0,84)
HueBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
HueBar.BorderSizePixel = 0
HueBar.ZIndex = 17
HueBar.ClipsDescendants = true
HueBar.Parent = LeftSection

local HueCorner = Instance.new("UICorner")
HueCorner.CornerRadius = UDim.new(0,4)
HueCorner.Parent = HueBar

local HueStroke = Instance.new("UIStroke")
HueStroke.Color = Theme.Border
HueStroke.Thickness = 1
HueStroke.Parent = HueBar

local HueGrad = Instance.new("UIGradient")
HueGrad.Rotation = 90
HueGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
    ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167,1,1)),
    ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333,1,1)),
    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
    ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667,1,1)),
    ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833,1,1)),
    ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
})
HueGrad.Parent = HueBar

local HueCursor = Instance.new("Frame")
HueCursor.Size = UDim2.new(1,4,0,6)
HueCursor.AnchorPoint = Vector2.new(0.5,0.5)
HueCursor.Position = UDim2.new(0.5,0,pickerHue,0)
HueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
HueCursor.BorderSizePixel = 0
HueCursor.ZIndex = 20
HueCursor.Parent = HueBar

local HueCursorCorner = Instance.new("UICorner")
HueCursorCorner.CornerRadius = UDim.new(0,3)
HueCursorCorner.Parent = HueCursor

local HueCursorStroke = Instance.new("UIStroke")
HueCursorStroke.Color = Color3.fromRGB(0,0,0)
HueCursorStroke.Thickness = 1
HueCursorStroke.Parent = HueCursor

local svDragging = false
local hueDragging = false

local function updateSV(absX, absY)
    local sx = SVFrame.AbsolutePosition.X
    local sy = SVFrame.AbsolutePosition.Y
    local sw = SVFrame.AbsoluteSize.X
    local sh = SVFrame.AbsoluteSize.Y
    pickerSat = math.clamp((absX - sx) / sw, 0, 1)
    pickerVal = math.clamp(1 - (absY - sy) / sh, 0, 1)
    SVCursor.Position = UDim2.new(pickerSat, 0, 1 - pickerVal, 0)
    updatePickerColor()
end

local function updateHue(absY)
    local hy = HueBar.AbsolutePosition.Y
    local hh = HueBar.AbsoluteSize.Y
    pickerHue = math.clamp((absY - hy) / hh, 0, 0.999)
    HueCursor.Position = UDim2.new(0.5, 0, pickerHue, 0)
    SVFrame.BackgroundColor3 = Color3.fromHSV(pickerHue, 1, 1)
    updatePickerColor()
end

SVFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        svDragging = true
        updateSV(input.Position.X, input.Position.Y)
    end
end)

HueBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hueDragging = true
        updateHue(input.Position.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if svDragging then updateSV(input.Position.X, input.Position.Y) end
        if hueDragging then updateHue(input.Position.Y) end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        svDragging = false
        hueDragging = false
    end
end)

local HexInput = Instance.new("TextBox")
HexInput.Size = UDim2.new(0,100,0,28)
HexInput.Position = UDim2.new(0,16 + SV_SIZE + 12 + HUE_W + 12,0,84)
HexInput.BackgroundColor3 = Color3.fromRGB(20,24,30)
HexInput.BorderSizePixel = 0
HexInput.Text = "#FF2D37"
HexInput.PlaceholderText = "#RRGGBB"
HexInput.TextColor3 = Theme.TextPrimary
HexInput.PlaceholderColor3 = Theme.TextSecondary
HexInput.Font = Enum.Font.GothamMedium
HexInput.TextSize = 12
HexInput.ZIndex = 17
HexInput.Parent = LeftSection

local HexCorner = Instance.new("UICorner")
HexCorner.CornerRadius = UDim.new(0,4)
HexCorner.Parent = HexInput

local HexStroke = Instance.new("UIStroke")
HexStroke.Color = Theme.Border
HexStroke.Thickness = 1
HexStroke.Parent = HexInput

HexInput.FocusLost:Connect(function()
    local txt = HexInput.Text
    txt = string.gsub(txt, "#", "")
    if #txt == 6 then
        local r = tonumber(string.sub(txt,1,2), 16)
        local g = tonumber(string.sub(txt,3,4), 16)
        local b = tonumber(string.sub(txt,5,6), 16)
        if r and g and b then
            local c = Color3.fromRGB(r,g,b)
            local h, s, v = Color3.toHSV(c)
            pickerHue = h
            pickerSat = s
            pickerVal = v
            SVFrame.BackgroundColor3 = Color3.fromHSV(pickerHue, 1, 1)
            SVCursor.Position = UDim2.new(pickerSat, 0, 1 - pickerVal, 0)
            HueCursor.Position = UDim2.new(0.5, 0, pickerHue, 0)
            updatePickerColor()
        end
    end
end)

local presetColors = {
    Color3.fromRGB(255,45,55),
    Color3.fromRGB(0,170,255),
    Color3.fromRGB(80,255,120),
    Color3.fromRGB(255,170,0),
    Color3.fromRGB(180,60,255),
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(255,80,180),
    Color3.fromRGB(0,255,200),
}

local PresetLabel = Instance.new("TextLabel")
PresetLabel.Size = UDim2.new(0,80,0,14)
PresetLabel.Position = UDim2.new(0,16 + SV_SIZE + 12 + HUE_W + 12,0,120)
PresetLabel.BackgroundTransparency = 1
PresetLabel.Text = "PRESETS"
PresetLabel.TextColor3 = Theme.TextSecondary
PresetLabel.Font = Enum.Font.GothamMedium
PresetLabel.TextSize = 10
PresetLabel.TextXAlignment = Enum.TextXAlignment.Left
PresetLabel.ZIndex = 17
PresetLabel.Parent = LeftSection

for i, pc in ipairs(presetColors) do
    local row = math.floor((i-1) / 4)
    local col = (i-1) % 4
    local pb = Instance.new("TextButton")
    pb.Size = UDim2.new(0,22,0,22)
    pb.Position = UDim2.new(0, 16 + SV_SIZE + 12 + HUE_W + 12 + col * 26, 0, 140 + row * 26)
    pb.BackgroundColor3 = pc
    pb.Text = ""
    pb.AutoButtonColor = false
    pb.ZIndex = 17
    pb.Parent = LeftSection

    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(0,4)
    pbc.Parent = pb

    local pbs = Instance.new("UIStroke")
    pbs.Color = Theme.Border
    pbs.Thickness = 1
    pbs.Parent = pb

    pb.MouseEnter:Connect(function() TweenService:Create(pbs, TweenInfo.new(0.15), {Color = Theme.BorderGlow}):Play() end)
    pb.MouseLeave:Connect(function() TweenService:Create(pbs, TweenInfo.new(0.15), {Color = Theme.Border}):Play() end)
    pb.MouseButton1Click:Connect(function()
        local h, s, v = Color3.toHSV(pc)
        pickerHue = h
        pickerSat = s
        pickerVal = v
        SVFrame.BackgroundColor3 = Color3.fromHSV(pickerHue, 1, 1)
        SVCursor.Position = UDim2.new(pickerSat, 0, 1 - pickerVal, 0)
        HueCursor.Position = UDim2.new(0.5, 0, pickerHue, 0)
        updatePickerColor()
        HexInput.Text = CPLabel.Text
    end)
end

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0,120,0,14)
ToggleLabel.Position = UDim2.new(0,16,0,300)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "OPTIONS"
ToggleLabel.TextColor3 = Theme.TextSecondary
ToggleLabel.Font = Enum.Font.GothamMedium
ToggleLabel.TextSize = 10
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.ZIndex = 17
ToggleLabel.Parent = LeftSection

local function createToggle(parent, label, yPos, default, callback)
    local toggleOn = default

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-32,0,36)
    container.Position = UDim2.new(0,16,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(20,24,30)
    container.BorderSizePixel = 0
    container.ZIndex = 17
    container.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0,6)
    cCorner.Parent = container

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Theme.Border
    cStroke.Thickness = 1
    cStroke.Parent = container

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1,-60,1,0)
    tLabel.Position = UDim2.new(0,12,0,0)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = label
    tLabel.TextColor3 = Theme.TextSecondary
    tLabel.Font = Enum.Font.GothamMedium
    tLabel.TextSize = 12
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 18
    tLabel.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0,40,0,22)
    toggleBg.Position = UDim2.new(1,-52,0.5,-11)
    toggleBg.BackgroundColor3 = toggleOn and Theme.Accent or Color3.fromRGB(35,40,50)
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 18
    toggleBg.Parent = container
    if toggleOn then table.insert(accentColorElements, {obj = toggleBg, type = "BackgroundColor3"}) end

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(1,0)
    tbCorner.Parent = toggleBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = toggleOn and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 19
    knob.Parent = toggleBg

    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(1,0)
    kCorner.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 20
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        toggleOn = not toggleOn
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = toggleOn and Theme.Accent or Color3.fromRGB(35,40,50)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = toggleOn and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
        if callback then callback(toggleOn) end
    end)

    return function() return toggleOn end, function(val)
        toggleOn = val
        toggleBg.BackgroundColor3 = toggleOn and Theme.Accent or Color3.fromRGB(35,40,50)
        knob.Position = toggleOn and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    end
end

local getAutoLoad, setAutoLoad = createToggle(LeftSection, "Auto Load Config", 320, autoLoadEnabled, function(val)
    autoLoadEnabled = val
    saveSettings()
end)

local getAutoSave, setAutoSave = createToggle(LeftSection, "Auto Save Config", 364, autoSaveEnabled, function(val)
    autoSaveEnabled = val
    saveSettings()
end)

local RightSection = Instance.new("Frame")
RightSection.Size = UDim2.new(0.5,-12,0,540)
RightSection.BackgroundColor3 = Color3.fromRGB(16,19,25)
RightSection.BorderSizePixel = 0
RightSection.ZIndex = 16
RightSection.LayoutOrder = 2
RightSection.Parent = SPScroll

local RSCorner = Instance.new("UICorner")
RSCorner.CornerRadius = UDim.new(0,6)
RSCorner.Parent = RightSection

local RSStroke = Instance.new("UIStroke")
RSStroke.Color = Theme.Border
RSStroke.Thickness = 1
RSStroke.Parent = RightSection

local RSTitle = Instance.new("TextLabel")
RSTitle.Size = UDim2.new(1,-20,0,36)
RSTitle.Position = UDim2.new(0,16,0,0)
RSTitle.BackgroundTransparency = 1
RSTitle.Text = "CONFIGURATIONS"
RSTitle.TextColor3 = Theme.TextSecondary
RSTitle.Font = Enum.Font.GothamMedium
RSTitle.TextSize = 11
RSTitle.TextXAlignment = Enum.TextXAlignment.Left
RSTitle.ZIndex = 17
RSTitle.Parent = RightSection

local CfgNameBox = Instance.new("TextBox")
CfgNameBox.Size = UDim2.new(1,-32,0,34)
CfgNameBox.Position = UDim2.new(0,16,0,42)
CfgNameBox.BackgroundColor3 = Color3.fromRGB(20,24,30)
CfgNameBox.BorderSizePixel = 0
CfgNameBox.Text = ""
CfgNameBox.PlaceholderText = "Config name..."
CfgNameBox.TextColor3 = Theme.TextPrimary
CfgNameBox.PlaceholderColor3 = Theme.TextSecondary
CfgNameBox.Font = Enum.Font.GothamMedium
CfgNameBox.TextSize = 13
CfgNameBox.ZIndex = 17
CfgNameBox.Parent = RightSection

local CNBCorner = Instance.new("UICorner")
CNBCorner.CornerRadius = UDim.new(0,4)
CNBCorner.Parent = CfgNameBox

local CNBStroke = Instance.new("UIStroke")
CNBStroke.Color = Theme.Border
CNBStroke.Thickness = 1
CNBStroke.Parent = CfgNameBox

local dropdownOpen = false
local dropdownFrame = nil

local DropBtn = Instance.new("TextButton")
DropBtn.Size = UDim2.new(1,-32,0,38)
DropBtn.Position = UDim2.new(0,16,0,84)
DropBtn.BackgroundColor3 = Color3.fromRGB(20,24,30)
DropBtn.Text = ""
DropBtn.AutoButtonColor = false
DropBtn.ZIndex = 17
DropBtn.Parent = RightSection

local DBCorner = Instance.new("UICorner")
DBCorner.CornerRadius = UDim.new(0,6)
DBCorner.Parent = DropBtn

local DBStroke = Instance.new("UIStroke")
DBStroke.Color = Theme.Border
DBStroke.Thickness = 1
DBStroke.Parent = DropBtn

local DropIcon = Instance.new("Frame")
DropIcon.Size = UDim2.new(0,24,0,24)
DropIcon.Position = UDim2.new(0,10,0.5,-12)
DropIcon.BackgroundColor3 = Theme.Accent
DropIcon.BorderSizePixel = 0
DropIcon.ZIndex = 18
DropIcon.Parent = DropBtn
table.insert(accentColorElements, {obj = DropIcon, type = "BackgroundColor3"})

local DropIconCorner = Instance.new("UICorner")
DropIconCorner.CornerRadius = UDim.new(0,4)
DropIconCorner.Parent = DropIcon

local DropIconLbl = Instance.new("TextLabel")
DropIconLbl.Size = UDim2.new(1,0,1,0)
DropIconLbl.BackgroundTransparency = 1
DropIconLbl.Text = "C"
DropIconLbl.TextColor3 = Color3.fromRGB(255,255,255)
DropIconLbl.Font = Enum.Font.GothamBold
DropIconLbl.TextSize = 11
DropIconLbl.ZIndex = 19
DropIconLbl.Parent = DropIcon

local DropText = Instance.new("TextLabel")
DropText.Size = UDim2.new(1,-80,1,0)
DropText.Position = UDim2.new(0,42,0,0)
DropText.BackgroundTransparency = 1
DropText.Text = "Select config..."
DropText.TextColor3 = Theme.TextSecondary
DropText.Font = Enum.Font.GothamMedium
DropText.TextSize = 12
DropText.TextXAlignment = Enum.TextXAlignment.Left
DropText.ZIndex = 18
DropText.Parent = DropBtn

local DropArrow = Instance.new("TextLabel")
DropArrow.Size = UDim2.new(0,20,1,0)
DropArrow.Position = UDim2.new(1,-28,0,0)
DropArrow.BackgroundTransparency = 1
DropArrow.Text = "▾"
DropArrow.TextColor3 = Theme.TextSecondary
DropArrow.Font = Enum.Font.GothamBold
DropArrow.TextSize = 14
DropArrow.ZIndex = 18
DropArrow.Parent = DropBtn

DropBtn.MouseEnter:Connect(function()
    TweenService:Create(DBStroke, TweenInfo.new(0.15), {Color = Theme.BorderGlow}):Play()
    TweenService:Create(DropText, TweenInfo.new(0.15), {TextColor3 = Theme.TextPrimary}):Play()
end)
DropBtn.MouseLeave:Connect(function()
    TweenService:Create(DBStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
    TweenService:Create(DropText, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary}):Play()
end)

local function refreshDropdown()
    if dropdownFrame then dropdownFrame:Destroy() dropdownFrame = nil end
    if not dropdownOpen then return end
    local configs = getConfigList()
    local itemH = 36
    local totalH = math.min(math.max(#configs, 1), 6) * itemH + 12

    dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1,-32,0,totalH)
    dropdownFrame.Position = UDim2.new(0,16,0,126)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(16,19,25)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ZIndex = 50
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = RightSection

    local DFCorner = Instance.new("UICorner")
    DFCorner.CornerRadius = UDim.new(0,6)
    DFCorner.Parent = dropdownFrame

    local DFStroke = Instance.new("UIStroke")
    DFStroke.Color = Theme.BorderGlow
    DFStroke.Thickness = 1
    DFStroke.Parent = dropdownFrame

    local DFScroll = Instance.new("ScrollingFrame")
    DFScroll.Size = UDim2.new(1,0,1,0)
    DFScroll.BackgroundTransparency = 1
    DFScroll.BorderSizePixel = 0
    DFScroll.ScrollBarThickness = 3
    DFScroll.ScrollBarImageColor3 = Theme.BorderGlow
    DFScroll.CanvasSize = UDim2.new(0,0,0,#configs * itemH + 12)
    DFScroll.ZIndex = 51
    DFScroll.Parent = dropdownFrame

    local DFLayout = Instance.new("UIListLayout")
    DFLayout.Padding = UDim.new(0,2)
    DFLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DFLayout.Parent = DFScroll

    local DFPad = Instance.new("UIPadding")
    DFPad.PaddingTop = UDim.new(0,6)
    DFPad.PaddingLeft = UDim.new(0,6)
    DFPad.PaddingRight = UDim.new(0,6)
    DFPad.Parent = DFScroll

    if #configs == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1,0,0,30)
        empty.BackgroundTransparency = 1
        empty.Text = "No configs saved"
        empty.TextColor3 = Theme.TextSecondary
        empty.Font = Enum.Font.GothamMedium
        empty.TextSize = 11
        empty.ZIndex = 52
        empty.Parent = DFScroll
    else
        for _, cfgName in ipairs(configs) do
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1,0,0,itemH - 2)
            item.BackgroundColor3 = Color3.fromRGB(20,24,30)
            item.Text = ""
            item.AutoButtonColor = false
            item.ZIndex = 52
            item.Parent = DFScroll

            local ICorner = Instance.new("UICorner")
            ICorner.CornerRadius = UDim.new(0,4)
            ICorner.Parent = item

            local IIcon = Instance.new("Frame")
            IIcon.Size = UDim2.new(0,20,0,20)
            IIcon.Position = UDim2.new(0,8,0.5,-10)
            IIcon.BackgroundColor3 = Theme.Accent
            IIcon.BorderSizePixel = 0
            IIcon.ZIndex = 53
            IIcon.Parent = item

            local IIconCorner = Instance.new("UICorner")
            IIconCorner.CornerRadius = UDim.new(0,3)
            IIconCorner.Parent = IIcon

            local IIconLbl = Instance.new("TextLabel")
            IIconLbl.Size = UDim2.new(1,0,1,0)
            IIconLbl.BackgroundTransparency = 1
            IIconLbl.Text = string.upper(string.sub(cfgName, 1, 1))
            IIconLbl.TextColor3 = Color3.fromRGB(255,255,255)
            IIconLbl.Font = Enum.Font.GothamBold
            IIconLbl.TextSize = 10
            IIconLbl.ZIndex = 54
            IIconLbl.Parent = IIcon

            local ILbl = Instance.new("TextLabel")
            ILbl.Size = UDim2.new(1,-44,1,0)
            ILbl.Position = UDim2.new(0,36,0,0)
            ILbl.BackgroundTransparency = 1
            ILbl.Text = cfgName
            ILbl.TextColor3 = Theme.TextSecondary
            ILbl.Font = Enum.Font.GothamMedium
            ILbl.TextSize = 12
            ILbl.TextXAlignment = Enum.TextXAlignment.Left
            ILbl.ZIndex = 53
            ILbl.Parent = item

            item.MouseEnter:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ItemHover}):Play()
                TweenService:Create(ILbl, TweenInfo.new(0.15), {TextColor3 = Theme.TextPrimary}):Play()
            end)
            item.MouseLeave:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20,24,30)}):Play()
                TweenService:Create(ILbl, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary}):Play()
            end)
            item.MouseButton1Click:Connect(function()
                currentConfigName = cfgName
                CfgNameBox.Text = cfgName
                DropText.Text = cfgName
                DropText.TextColor3 = Theme.TextPrimary
                DropIconLbl.Text = string.upper(string.sub(cfgName, 1, 1))
                dropdownOpen = false
                TweenService:Create(DropArrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                refreshDropdown()
            end)
        end
    end
end

DropBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    TweenService:Create(DropArrow, TweenInfo.new(0.2), {Rotation = dropdownOpen and 180 or 0}):Play()
    refreshDropdown()
end)

local cfgBtnYBase = 130

local function makeCfgBtn(text, xOff, width, yOff, accent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,width,0,32)
    btn.Position = UDim2.new(0,xOff,0,cfgBtnYBase + yOff)
    btn.BackgroundColor3 = accent and Color3.fromRGB(40,20,25) or Color3.fromRGB(20,24,30)
    btn.Text = text
    btn.TextColor3 = Theme.TextPrimary
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.ZIndex = 17
    btn.Parent = RightSection

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,4)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = accent and Theme.Accent or Theme.Border
    bs.Thickness = 1
    bs.Parent = btn
    if accent then table.insert(accentColorElements, {obj = bs, type = "Color"}) end

    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = accent and Theme.Accent or Theme.ItemHover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = accent and Color3.fromRGB(40,20,25) or Color3.fromRGB(20,24,30)}):Play() end)

    return btn
end

local SaveBtn = makeCfgBtn("SAVE", 16, 80, 0, true)
local LoadBtn = makeCfgBtn("LOAD", 104, 80, 0, false)
local RewriteBtn = makeCfgBtn("REWRITE", 192, 90, 0, false)
local DeleteBtn = makeCfgBtn("DELETE", 290, 80, 0, false)

local function syncPickerToAccent()
    local c = Theme.Accent
    local h, s, v = Color3.toHSV(c)
    pickerHue = h
    pickerSat = s
    pickerVal = v
    SVFrame.BackgroundColor3 = Color3.fromHSV(pickerHue, 1, 1)
    SVCursor.Position = UDim2.new(pickerSat, 0, 1 - pickerVal, 0)
    HueCursor.Position = UDim2.new(0.5, 0, pickerHue, 0)
    local r = math.floor(c.R * 255)
    local g = math.floor(c.G * 255)
    local b = math.floor(c.B * 255)
    HexInput.Text = string.format("#%02X%02X%02X", r, g, b)
    CPLabel.Text = HexInput.Text
    ColorPreview.BackgroundColor3 = c
end

SaveBtn.MouseButton1Click:Connect(function()
    local name = CfgNameBox.Text
    if name == "" then return end
    if saveConfig(name) then
        currentConfigName = name
        DropText.Text = name
        DropText.TextColor3 = Theme.TextPrimary
        DropIconLbl.Text = string.upper(string.sub(name, 1, 1))
        saveSettings()
        if dropdownOpen then refreshDropdown() end
    end
end)

LoadBtn.MouseButton1Click:Connect(function()
    local name = CfgNameBox.Text
    if name ~= "" then
        if loadConfig(name) then
            currentConfigName = name
            syncPickerToAccent()
            saveSettings()
        end
    end
end)

RewriteBtn.MouseButton1Click:Connect(function()
    local name = CfgNameBox.Text
    if name ~= "" then
        saveConfig(name)
        if dropdownOpen then refreshDropdown() end
    end
end)

DeleteBtn.MouseButton1Click:Connect(function()
    local name = CfgNameBox.Text
    if name ~= "" then
        deleteConfig(name)
        if currentConfigName == name then currentConfigName = "" end
        CfgNameBox.Text = ""
        DropText.Text = "Select config..."
        DropText.TextColor3 = Theme.TextSecondary
        DropIconLbl.Text = "C"
        dropdownOpen = false
        refreshDropdown()
        saveSettings()
    end
end)

local CfgListLabel = Instance.new("TextLabel")
CfgListLabel.Size = UDim2.new(1,-32,0,20)
CfgListLabel.Position = UDim2.new(0,16,0,cfgBtnYBase + 44)
CfgListLabel.BackgroundTransparency = 1
CfgListLabel.Text = "SAVED CONFIGS"
CfgListLabel.TextColor3 = Theme.TextSecondary
CfgListLabel.Font = Enum.Font.GothamMedium
CfgListLabel.TextSize = 10
CfgListLabel.TextXAlignment = Enum.TextXAlignment.Left
CfgListLabel.ZIndex = 17
CfgListLabel.Parent = RightSection

local CfgListScroll = Instance.new("ScrollingFrame")
CfgListScroll.Size = UDim2.new(1,-32,0,300)
CfgListScroll.Position = UDim2.new(0,16,0,cfgBtnYBase + 68)
CfgListScroll.BackgroundColor3 = Color3.fromRGB(14,17,22)
CfgListScroll.BorderSizePixel = 0
CfgListScroll.ScrollBarThickness = 3
CfgListScroll.ScrollBarImageColor3 = Theme.BorderGlow
CfgListScroll.ZIndex = 17
CfgListScroll.Parent = RightSection

local CLSCorner = Instance.new("UICorner")
CLSCorner.CornerRadius = UDim.new(0,4)
CLSCorner.Parent = CfgListScroll

local CLSStroke = Instance.new("UIStroke")
CLSStroke.Color = Theme.Border
CLSStroke.Thickness = 1
CLSStroke.Parent = CfgListScroll

local CLSLayout = Instance.new("UIListLayout")
CLSLayout.Padding = UDim.new(0,2)
CLSLayout.SortOrder = Enum.SortOrder.LayoutOrder
CLSLayout.Parent = CfgListScroll

local CLSPad = Instance.new("UIPadding")
CLSPad.PaddingTop = UDim.new(0,4)
CLSPad.PaddingLeft = UDim.new(0,4)
CLSPad.PaddingRight = UDim.new(0,4)
CLSPad.Parent = CfgListScroll

local function refreshConfigList()
    for _, c in pairs(CfgListScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local configs = getConfigList()
    for _, cfgName in ipairs(configs) do
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1,0,0,32)
        item.BackgroundColor3 = (cfgName == currentConfigName) and Color3.fromRGB(30,34,44) or Color3.fromRGB(20,24,30)
        item.Text = ""
        item.AutoButtonColor = false
        item.ZIndex = 18
        item.Parent = CfgListScroll

        local iCorner = Instance.new("UICorner")
        iCorner.CornerRadius = UDim.new(0,4)
        iCorner.Parent = item

        local iDot = Instance.new("Frame")
        iDot.Size = UDim2.new(0,8,0,8)
        iDot.Position = UDim2.new(0,10,0.5,-4)
        iDot.BackgroundColor3 = (cfgName == currentConfigName) and Theme.Accent or Theme.TextSecondary
        iDot.BorderSizePixel = 0
        iDot.ZIndex = 19
        iDot.Parent = item

        local iDotCorner = Instance.new("UICorner")
        iDotCorner.CornerRadius = UDim.new(1,0)
        iDotCorner.Parent = iDot

        local iLbl = Instance.new("TextLabel")
        iLbl.Size = UDim2.new(1,-30,1,0)
        iLbl.Position = UDim2.new(0,26,0,0)
        iLbl.BackgroundTransparency = 1
        iLbl.Text = cfgName
        iLbl.TextColor3 = (cfgName == currentConfigName) and Theme.TextPrimary or Theme.TextSecondary
        iLbl.Font = Enum.Font.GothamMedium
        iLbl.TextSize = 11
        iLbl.TextXAlignment = Enum.TextXAlignment.Left
        iLbl.ZIndex = 19
        iLbl.Parent = item

        item.MouseEnter:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ItemHover}):Play()
            TweenService:Create(iLbl, TweenInfo.new(0.15), {TextColor3 = Theme.TextPrimary}):Play()
        end)
        item.MouseLeave:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.15), {BackgroundColor3 = (cfgName == currentConfigName) and Color3.fromRGB(30,34,44) or Color3.fromRGB(20,24,30)}):Play()
            TweenService:Create(iLbl, TweenInfo.new(0.15), {TextColor3 = (cfgName == currentConfigName) and Theme.TextPrimary or Theme.TextSecondary}):Play()
        end)
        item.MouseButton1Click:Connect(function()
            currentConfigName = cfgName
            CfgNameBox.Text = cfgName
            DropText.Text = cfgName
            DropText.TextColor3 = Theme.TextPrimary
            DropIconLbl.Text = string.upper(string.sub(cfgName, 1, 1))
            refreshConfigList()
        end)
    end
    CfgListScroll.CanvasSize = UDim2.new(0,0,0,#configs * 34 + 8)
end

local origSave = SaveBtn.MouseButton1Click
task.spawn(function()
    task.wait(0.1)
    refreshConfigList()
end)

local oldSaveClick
do
    local conns = SaveBtn.MouseButton1Click:Connect(function()
        task.wait(0.1)
        refreshConfigList()
    end)
end

DeleteBtn.MouseButton1Click:Connect(function()
    task.wait(0.1)
    refreshConfigList()
end)

SettingsBtn.MouseButton1Click:Connect(function()
    settingsOpen = not settingsOpen
    if settingsOpen then
        refreshConfigList()
        TweenService:Create(SettingsPanel, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,55)}):Play()
        TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.Accent}):Play()
    else
        TweenService:Create(SettingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(0,0,0,-720)}):Play()
        TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.TextSecondary}):Play()
        if autoSaveEnabled and currentConfigName ~= "" then
            saveConfig(currentConfigName)
        end
        saveSettings()
    end
end)

local LoadoutContainer = Instance.new("Frame")
LoadoutContainer.Name = "LoadoutContainer"
LoadoutContainer.Size = UDim2.new(1,0,1,-55)
LoadoutContainer.Position = UDim2.new(0,0,0,55)
LoadoutContainer.BackgroundTransparency = 1
LoadoutContainer.Parent = MainFrame

local function createCategory(name, xOffset, items)
    local Col = Instance.new("Frame")
    Col.Name = name
    Col.Size = UDim2.new(0.333,-24,1,-40)
    Col.Position = UDim2.new(xOffset,12,0,20)
    Col.BackgroundTransparency = 1
    Col.Parent = LoadoutContainer

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1,0,0,24)
    Header.BackgroundTransparency = 1
    Header.Text = string.upper(name)
    Header.TextColor3 = Theme.TextSecondary
    Header.Font = Enum.Font.GothamMedium
    Header.TextSize = 11
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Col

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1,0,1,-30)
    Scroll.Position = UDim2.new(0,0,0,30)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 1
    Scroll.ScrollBarImageColor3 = Theme.BorderGlow
    Scroll.Parent = Col

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0,6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    table.sort(items)

    task.spawn(function()
        for i, w in ipairs(items) do
            local Btn = Instance.new("TextButton")
            Btn.Name = w
            Btn.Size = UDim2.new(1,-12,0,50)
            Btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = Scroll

            local BtnGrad = Instance.new("UIGradient")
            BtnGrad.Rotation = 90
            BtnGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.ItemBg), ColorSequenceKeypoint.new(1, Theme.SectionBg)})
            BtnGrad.Parent = Btn

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0,4)
            Corner.Parent = Btn

            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Theme.Border
            Stroke.Thickness = 1
            Stroke.Parent = Btn

            local Selector = Instance.new("Frame")
            Selector.Size = UDim2.new(0,3,0,0)
            Selector.Position = UDim2.new(0,0,0.5,0)
            Selector.AnchorPoint = Vector2.new(0,0.5)
            Selector.BackgroundColor3 = Theme.Accent
            Selector.BorderSizePixel = 0
            Selector.Parent = Btn
            table.insert(accentColorElements, {obj = Selector, type = "BackgroundColor3"})

            local SelCorner = Instance.new("UICorner")
            SelCorner.CornerRadius = UDim.new(0,4)
            SelCorner.Parent = Selector

            local listVPF = Instance.new("ViewportFrame")
            listVPF.Size = UDim2.new(0,40,1,0)
            listVPF.Position = UDim2.new(0,10,0,0)
            listVPF.BackgroundTransparency = 1
            listVPF.Ambient = Color3.fromRGB(200,200,210)
            listVPF.LightColor = Color3.fromRGB(255,255,255)
            listVPF.LightDirection = Vector3.new(-1,-1,-0.5)
            listVPF.Parent = Btn

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1,-65,1,0)
            Lbl.Position = UDim2.new(0,55,0,0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = w
            Lbl.TextColor3 = Theme.TextSecondary
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Btn

            Btn.MouseEnter:Connect(function()
                BtnGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.ItemHover), ColorSequenceKeypoint.new(1, Theme.ItemBg)})
                TweenService:Create(Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = Theme.BorderGlow}):Play()
                TweenService:Create(Selector, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0,3,0,22)}):Play()
                TweenService:Create(Lbl, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {TextColor3 = Theme.TextPrimary, Position = UDim2.new(0,61,0,0)}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                BtnGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.ItemBg), ColorSequenceKeypoint.new(1, Theme.SectionBg)})
                TweenService:Create(Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Color = Theme.Border}):Play()
                TweenService:Create(Selector, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Size = UDim2.new(0,3,0,0)}):Play()
                TweenService:Create(Lbl, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {TextColor3 = Theme.TextSecondary, Position = UDim2.new(0,55,0,0)}):Play()
            end)
            Btn.MouseButton1Click:Connect(function() _G.OpenSkinMenu(w) end)

            local targetName = w
            if weaponSkins[w] and weaponSkins[w][1] then targetName = weaponSkins[w][1] end
            local asset = GetAsset(targetName, "Weapon") or GetAsset(w, "Weapon")
            if asset then
                local mdl, dim = SafeCloneModel(asset, true)
                if mdl then
                    mdl.Parent = listVPF
                    local cam = Instance.new("Camera")
                    listVPF.CurrentCamera = cam
                    cam.Parent = listVPF
                    cam.CFrame = CFrame.new(Vector3.new(0,0,dim * 1.5), Vector3.new(0,0,0))
                    mdl:PivotTo(CFrame.Angles(0, math.rad(65), 0))
                end
            end
            task.wait()
        end
        Scroll.CanvasSize = UDim2.new(0,0,0,#items * 56)
    end)
end

createCategory("Pistols", 0, Categories.Pistols)
createCategory("Mid-Tier", 0.333, Categories.MidTier)
createCategory("Rifles", 0.666, Categories.Rifles)

local SkinContainer = Instance.new("Frame")
SkinContainer.Name = "SkinContainer"
SkinContainer.Size = UDim2.new(1,0,1,-55)
SkinContainer.Position = UDim2.new(1,0,0,55)
SkinContainer.BackgroundTransparency = 1
SkinContainer.Visible = false
SkinContainer.Parent = MainFrame

local ShowcaseBox = Instance.new("Frame")
ShowcaseBox.Size = UDim2.new(1,0,0,340)
ShowcaseBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
ShowcaseBox.BorderSizePixel = 0
ShowcaseBox.Parent = SkinContainer

local ShowcaseGrad = Instance.new("UIGradient")
ShowcaseGrad.Rotation = 90
ShowcaseGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.MainBg),
    ColorSequenceKeypoint.new(0.5, Theme.SectionBg),
    ColorSequenceKeypoint.new(1, Theme.MainBg)
})
ShowcaseGrad.Parent = ShowcaseBox

local FloorLight = Instance.new("Frame")
FloorLight.Size = UDim2.new(1,0,0,80)
FloorLight.Position = UDim2.new(0,0,1,-40)
FloorLight.BackgroundColor3 = Color3.fromRGB(255,255,255)
FloorLight.BorderSizePixel = 0
FloorLight.Parent = ShowcaseBox

local FloorGrad = Instance.new("UIGradient")
FloorGrad.Rotation = 90
FloorGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.MainBg)
})
FloorGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.9),
    NumberSequenceKeypoint.new(1, 1)
})
FloorGrad.Parent = FloorLight
table.insert(accentColorElements, {obj = FloorGrad, type = "Color"})

local Spotlight = Instance.new("ImageLabel")
Spotlight.Size = UDim2.new(0,700,0,700)
Spotlight.Position = UDim2.new(0.5,-350,0.5,-350)
Spotlight.BackgroundTransparency = 1
Spotlight.Image = "rbxassetid://5028857472"
Spotlight.ImageColor3 = Color3.fromRGB(150,160,200)
Spotlight.ImageTransparency = 0.88
Spotlight.Parent = ShowcaseBox

local VPF = Instance.new("ViewportFrame")
VPF.Size = UDim2.new(1,0,1,0)
VPF.BackgroundTransparency = 1
VPF.Ambient = Color3.fromRGB(170,170,180)
VPF.LightColor = Color3.fromRGB(255,255,255)
VPF.LightDirection = Vector3.new(-1,-1,-0.5)
VPF.Active = true
VPF.Parent = ShowcaseBox

local Cam = Instance.new("Camera")
VPF.CurrentCamera = Cam
Cam.Parent = VPF

local ShowcaseImage = Instance.new("ImageLabel")
ShowcaseImage.Size = UDim2.new(0,250,0,250)
ShowcaseImage.Position = UDim2.new(0.5,-125,0.5,-125)
ShowcaseImage.BackgroundTransparency = 1
ShowcaseImage.ScaleType = Enum.ScaleType.Fit
ShowcaseImage.Visible = false
ShowcaseImage.ZIndex = 5
ShowcaseImage.Parent = ShowcaseBox

local TopControls = Instance.new("Frame")
TopControls.Size = UDim2.new(1,0,0,60)
TopControls.BackgroundTransparency = 1
TopControls.Parent = SkinContainer

local BackBtn = Instance.new("TextButton")
BackBtn.Size = UDim2.new(0,80,0,28)
BackBtn.Position = UDim2.new(0,20,0,16)
BackBtn.BackgroundColor3 = Theme.SectionBg
BackBtn.Text = "BACK"
BackBtn.TextColor3 = Theme.TextSecondary
BackBtn.Font = Enum.Font.GothamMedium
BackBtn.TextSize = 11
BackBtn.AutoButtonColor = false
BackBtn.Parent = TopControls

local BackCorner = Instance.new("UICorner")
BackCorner.CornerRadius = UDim.new(0,4)
BackCorner.Parent = BackBtn

local BackStroke = Instance.new("UIStroke")
BackStroke.Color = Theme.Border
BackStroke.Parent = BackBtn

BackBtn.MouseEnter:Connect(function() TweenService:Create(BackBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ItemHover, TextColor3 = Theme.TextPrimary}):Play() end)
BackBtn.MouseLeave:Connect(function() TweenService:Create(BackBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SectionBg, TextColor3 = Theme.TextSecondary}):Play() end)

local WepLabel = Instance.new("TextLabel")
WepLabel.Size = UDim2.new(0,300,1,0)
WepLabel.Position = UDim2.new(0.5,-150,0,0)
WepLabel.BackgroundTransparency = 1
WepLabel.Text = ""
WepLabel.TextColor3 = Theme.TextPrimary
WepLabel.Font = Enum.Font.GothamBold
WepLabel.TextSize = 18
WepLabel.Parent = TopControls

local GridSection = Instance.new("Frame")
GridSection.Size = UDim2.new(1,0,1,-340)
GridSection.Position = UDim2.new(0,0,0,340)
GridSection.BackgroundColor3 = Theme.SectionBg
GridSection.BorderSizePixel = 0
GridSection.Parent = SkinContainer

local GridLine = Instance.new("Frame")
GridLine.Size = UDim2.new(1,0,0,1)
GridLine.BackgroundColor3 = Theme.Border
GridLine.BorderSizePixel = 0
GridLine.Parent = GridSection

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,40)
TabBar.BackgroundColor3 = Theme.SectionBg
TabBar.BorderSizePixel = 0
TabBar.Parent = GridSection

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabBar

local currentTab = "Skin"
local tabBtns = {}

local SkinScroll = Instance.new("ScrollingFrame")
SkinScroll.Size = UDim2.new(1,-40,1,-100)
SkinScroll.Position = UDim2.new(0,20,0,50)
SkinScroll.BackgroundTransparency = 1
SkinScroll.BorderSizePixel = 0
SkinScroll.ScrollBarThickness = 2
SkinScroll.ScrollBarImageColor3 = Theme.BorderGlow
SkinScroll.Parent = GridSection

local GridLayout = Instance.new("UIGridLayout")
GridLayout.CellSize = UDim2.new(0,150,0,150)
GridLayout.CellPadding = UDim2.new(0,12,0,12)
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
GridLayout.Parent = SkinScroll

local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1,0,0,60)
BottomBar.Position = UDim2.new(0,0,1,-60)
BottomBar.BackgroundColor3 = Theme.SectionBg
BottomBar.BorderSizePixel = 0
BottomBar.ZIndex = 10
BottomBar.Parent = GridSection

local BottomLine2 = Instance.new("Frame")
BottomLine2.Size = UDim2.new(1,0,0,1)
BottomLine2.BackgroundColor3 = Theme.Border
BottomLine2.BorderSizePixel = 0
BottomLine2.ZIndex = 11
BottomLine2.Parent = BottomBar

SkinScroll.Size = UDim2.new(1,-40,1,-110)
SkinScroll.Position = UDim2.new(0,20,0,50)

local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Size = UDim2.new(0,200,0,42)
ApplyBtn.Position = UDim2.new(1,-210,0.5,-21)
ApplyBtn.BackgroundColor3 = Color3.fromRGB(40,20,25)
ApplyBtn.Text = "APPLY"
ApplyBtn.TextColor3 = Color3.fromRGB(255,255,255)
ApplyBtn.Font = Enum.Font.GothamBold
ApplyBtn.TextSize = 13
ApplyBtn.AutoButtonColor = false
ApplyBtn.ZIndex = 11
ApplyBtn.Parent = BottomBar

local ApplyCorner = Instance.new("UICorner")
ApplyCorner.CornerRadius = UDim.new(0,4)
ApplyCorner.Parent = ApplyBtn

local ApplyStroke = Instance.new("UIStroke")
ApplyStroke.Color = Theme.Accent
ApplyStroke.Thickness = 1
ApplyStroke.Parent = ApplyBtn
table.insert(accentColorElements, {obj = ApplyStroke, type = "Color"})

ApplyBtn.MouseEnter:Connect(function() TweenService:Create(ApplyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play() end)
ApplyBtn.MouseLeave:Connect(function() TweenService:Create(ApplyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,20,25)}):Play() end)

local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(0,140,0,42)
AutoBtn.Position = UDim2.new(0,10,0.5,-21)
AutoBtn.BackgroundColor3 = Color3.fromRGB(35,40,50)
AutoBtn.Text = "AUTO SPIN"
AutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
AutoBtn.Font = Enum.Font.GothamMedium
AutoBtn.TextSize = 12
AutoBtn.AutoButtonColor = false
AutoBtn.ZIndex = 11
AutoBtn.Parent = BottomBar

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0,4)
AutoCorner.Parent = AutoBtn

local AutoStroke = Instance.new("UIStroke")
AutoStroke.Color = Color3.fromRGB(80,90,110)
AutoStroke.Thickness = 1
AutoStroke.Parent = AutoBtn

local currentWeapon = nil
local currentCosmetic = nil
local activeModel = nil
local spinning = true
local mDragging = false
local lastM = nil
local rotX, rotY, curX, curY = 0, 0, 0, 0
local camZ = 11
local mouseOverVPF = false

VPF.MouseEnter:Connect(function() mouseOverVPF = true end)
VPF.MouseLeave:Connect(function() mouseOverVPF = false end)

VPF.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = true
        lastM = input.Position
        if spinning then
            spinning = false
            TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,24,30), TextColor3 = Theme.TextSecondary}):Play()
            TweenService:Create(AutoStroke, TweenInfo.new(0.2), {Color = Theme.Border}):Play()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if mDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if lastM then
            local delta = input.Position - lastM
            rotX = math.clamp(rotX + math.rad(delta.Y * 0.6), -math.rad(80), math.rad(80))
            rotY = rotY + math.rad(delta.X * 0.6)
            lastM = input.Position
        end
    end
    if input.UserInputType == Enum.UserInputType.MouseWheel and mouseOverVPF then
        camZ = math.clamp(camZ - input.Position.Z * 1.5, 3, 25)
        if Cam then Cam.CFrame = CFrame.new(Vector3.new(0,0,camZ), Vector3.new(0,0,0)) end
    end
end)

AutoBtn.MouseEnter:Connect(function()
    TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = spinning and Color3.fromRGB(45,50,60) or Color3.fromRGB(25,29,35)}):Play()
end)
AutoBtn.MouseLeave:Connect(function()
    TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = spinning and Color3.fromRGB(35,40,50) or Color3.fromRGB(20,24,30)}):Play()
end)
AutoBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    if spinning then
        TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,50,60), TextColor3 = Color3.fromRGB(255,255,255)}):Play()
        TweenService:Create(AutoStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(80,90,110)}):Play()
    else
        TweenService:Create(AutoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25,29,35), TextColor3 = Theme.TextSecondary}):Play()
        TweenService:Create(AutoStroke, TweenInfo.new(0.2), {Color = Theme.Border}):Play()
    end
end)

local function getPreviewModel(name, cosType, wep)
    local asset = nil
    if cosType == "Wrap" then
        asset = GetAsset(wep, "Weapon")
    else
        asset = GetAsset(name, cosType)
        if not asset and cosType == "Skin" then asset = GetAsset(name, "Weapon") end
    end
    if not asset then return nil, 5 end
    local mdl, maxDim = SafeCloneModel(asset, false)
    if mdl and cosType == "Wrap" then ApplyWrapToModel(mdl, name) end
    return mdl, maxDim
end

local function selectCosmetic(name)
    currentCosmetic = name
    for _, c in pairs(SkinScroll:GetChildren()) do
        if c:IsA("TextButton") then
            local isSelected = c.Name == name
            local stroke = c:FindFirstChild("TStroke")
            local rareLine = c:FindFirstChild("RareLine")
            local infoBar = c:FindFirstChild("InfoBar")
            if stroke then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = isSelected and Theme.Accent or Theme.Border}):Play() end
            if rareLine then TweenService:Create(rareLine, TweenInfo.new(0.2), {BackgroundColor3 = isSelected and Theme.Accent or Theme.Border}):Play() end
            if infoBar and infoBar:FindFirstChild("Lbl") then
                TweenService:Create(infoBar.Lbl, TweenInfo.new(0.2), {TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary}):Play()
            end
        end
    end

    if activeModel then activeModel:Destroy() activeModel = nil end
    for _, child in pairs(VPF:GetChildren()) do
        if child:IsA("WorldModel") or child:IsA("Model") then child:Destroy() end
    end

    ShowcaseImage.Visible = false
    VPF.Visible = false

    task.spawn(function()
        if currentTab == "Finisher" then
            ShowcaseImage.Visible = true
            local imgId = ""
            if CosmeticLibrary and CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name] then
                imgId = CosmeticLibrary.Cosmetics[name].Image or ""
            end
            ShowcaseImage.Image = imgId
        else
            VPF.Visible = true
            local mdl, maxDim = getPreviewModel(name, currentTab, currentWeapon)
            if mdl and currentCosmetic == name then
                activeModel = mdl
                local wm = Instance.new("WorldModel")
                wm.Parent = VPF
                activeModel.Parent = wm
                activeModel:PivotTo(CFrame.new(0,0,0))
                camZ = 11
                Cam.CFrame = CFrame.new(Vector3.new(0,0,camZ), Vector3.new(0,0,0))
                pcall(function() activeModel:ScaleTo(7.8 / maxDim) end)
                rotX, rotY, curX, curY = 0, 0, 0, 0
                PlayIdleAnimation(activeModel)
            end
        end
    end)
end

local MAX_VISIBLE_TILES = 60
local allCurrentItems = {}
local loadedTileCount = 0
local isLoadingMore = false

local function clearGrid()
    for _, c in pairs(SkinScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    loadedTileCount = 0
end

local function loadBatch(startIdx, count)
    if isLoadingMore then return end
    isLoadingMore = true
    local endIdx = math.min(startIdx + count - 1, #allCurrentItems)
    for i = startIdx, endIdx do
        if currentLoadId ~= _G._phantomLoadId then isLoadingMore = false return end
        buildTile(allCurrentItems[i], currentTab)
        loadedTileCount = loadedTileCount + 1
        if i % 3 == 0 then task.wait() end
    end
    local cols = math.max(1, math.floor((SkinScroll.AbsoluteSize.X + 12) / 162))
    local rows = math.ceil(loadedTileCount / cols)
    SkinScroll.CanvasSize = UDim2.new(0, 0, 0, rows * 162 + 20)
    isLoadingMore = false
end

SkinScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if isLoadingMore then return end
    local scrollPos = SkinScroll.CanvasPosition.Y
    local canvasH = SkinScroll.CanvasSize.Y.Offset
    local frameH = SkinScroll.AbsoluteSize.Y
    if canvasH - scrollPos - frameH < 200 then
        if loadedTileCount < #allCurrentItems then
            loadBatch(loadedTileCount + 1, 20)
        end
    end
end)

local function buildTile(name, cosmeticType)
    local Tile = Instance.new("TextButton")
    Tile.Name = name
    Tile.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Tile.Text = ""
    Tile.AutoButtonColor = false
    Tile.ClipsDescendants = true
    Tile.Parent = SkinScroll

    local TGrad = Instance.new("UIGradient")
    TGrad.Rotation = 45
    TGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.ItemBg), ColorSequenceKeypoint.new(1, Theme.MainBg)})
    TGrad.Parent = Tile

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0,4)
    TCorner.Parent = Tile

    local TStroke = Instance.new("UIStroke")
    TStroke.Name = "TStroke"
    TStroke.Color = Theme.Border
    TStroke.Parent = Tile

    local InfoBar = Instance.new("Frame")
    InfoBar.Name = "InfoBar"
    InfoBar.Size = UDim2.new(1,0,0,30)
    InfoBar.Position = UDim2.new(0,0,1,-30)
    InfoBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
    InfoBar.BackgroundTransparency = 0.6
    InfoBar.BorderSizePixel = 0
    InfoBar.ZIndex = 2
    InfoBar.Parent = Tile

    local RareLine = Instance.new("Frame")
    RareLine.Name = "RareLine"
    RareLine.Size = UDim2.new(1,0,0,2)
    RareLine.Position = UDim2.new(0,0,1,-2)
    RareLine.BackgroundColor3 = Theme.Border
    RareLine.BorderSizePixel = 0
    RareLine.ZIndex = 3
    RareLine.Parent = Tile

    local Lbl = Instance.new("TextLabel")
    Lbl.Name = "Lbl"
    Lbl.Size = UDim2.new(1,-20,1,0)
    Lbl.Position = UDim2.new(0,10,0,-1)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = name
    Lbl.TextColor3 = Theme.TextSecondary
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 3
    Lbl.Parent = InfoBar

    if cosmeticType == "Finisher" then
        local imgId = ""
        if CosmeticLibrary and CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name] then
            imgId = CosmeticLibrary.Cosmetics[name].Image or ""
        end
        local Img = Instance.new("ImageLabel")
        Img.Size = UDim2.new(0,80,0,80)
        Img.Position = UDim2.new(0.5,-40,0.5,-55)
        Img.BackgroundTransparency = 1
        Img.ScaleType = Enum.ScaleType.Fit
        Img.Image = imgId
        Img.ZIndex = 1
        Img.Parent = Tile
    else
        local T_VPF = Instance.new("ViewportFrame")
        T_VPF.Size = UDim2.new(1,0,1,-30)
        T_VPF.BackgroundTransparency = 1
        T_VPF.Ambient = Color3.fromRGB(190,190,200)
        T_VPF.LightColor = Color3.fromRGB(255,255,255)
        T_VPF.LightDirection = Vector3.new(-1,-1,-0.5)
        T_VPF.ZIndex = 1
        T_VPF.Parent = Tile

        task.spawn(function()
            local asset = nil
            if cosmeticType == "Wrap" then
                asset = GetAsset(currentWeapon, "Weapon")
            else
                asset = GetAsset(name, cosmeticType)
                if not asset and cosmeticType == "Skin" then asset = GetAsset(name, "Weapon") end
            end
            if asset then
                local mdl, maxDim = SafeCloneModel(asset, true)
                if mdl then
                    if cosmeticType == "Wrap" then ApplyWrapToModel(mdl, name) end
                    mdl.Parent = T_VPF
                    local T_Cam = Instance.new("Camera")
                    T_VPF.CurrentCamera = T_Cam
                    T_Cam.Parent = T_VPF
                    T_Cam.CFrame = CFrame.new(Vector3.new(0,0,maxDim * 1.4), Vector3.new(0,0,0))
                    mdl:PivotTo(CFrame.Angles(0, math.rad(55), 0))
                end
            end
        end)
    end

    Tile.MouseEnter:Connect(function()
        TGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.ItemHover), ColorSequenceKeypoint.new(1, Theme.SectionBg)})
        if currentCosmetic ~= name then
            TweenService:Create(TStroke, TweenInfo.new(0.2), {Color = Theme.BorderGlow}):Play()
            TweenService:Create(Lbl, TweenInfo.new(0.2), {TextColor3 = Theme.TextPrimary}):Play()
        end
    end)
    Tile.MouseLeave:Connect(function()
        TGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.ItemBg), ColorSequenceKeypoint.new(1, Theme.MainBg)})
        if currentCosmetic ~= name then
            TweenService:Create(TStroke, TweenInfo.new(0.25), {Color = Theme.Border}):Play()
            TweenService:Create(Lbl, TweenInfo.new(0.25), {TextColor3 = Theme.TextSecondary}):Play()
        end
    end)
    Tile.MouseButton1Click:Connect(function() selectCosmetic(name) end)
    return Tile
end

local currentLoadId = 0
_G._phantomLoadId = 0

local function loadCosmeticGrid()
    currentLoadId = currentLoadId + 1
    _G._phantomLoadId = currentLoadId
    local myLoadId = currentLoadId
    clearGrid()

    local items = {}
    if currentTab == "Skin" then items = weaponSkins[currentWeapon] or {}
    elseif currentTab == "Wrap" then items = DynamicLists.Wrap
    elseif currentTab == "Charm" then items = DynamicLists.Charm
    elseif currentTab == "Finisher" then items = DynamicLists.Finisher end

    allCurrentItems = items

    local initialBatch = math.min(#items, MAX_VISIBLE_TILES)

    task.spawn(function()
        for i = 1, initialBatch do
            if _G._phantomLoadId ~= myLoadId then return end
            buildTile(items[i], currentTab)
            loadedTileCount = loadedTileCount + 1
            if i % 3 == 0 then task.wait() end
        end

        local cols = math.max(1, math.floor((SkinScroll.AbsoluteSize.X + 12) / 162))
        local totalRows = math.ceil(#items / cols)
        SkinScroll.CanvasSize = UDim2.new(0, 0, 0, totalRows * 162 + 20)

        if _G._phantomLoadId == myLoadId and #items > 0 then
            selectCosmetic(items[1])
        elseif #items == 0 and _G._phantomLoadId == myLoadId then
            currentCosmetic = nil
            if activeModel then activeModel:Destroy() activeModel = nil end
            ShowcaseImage.Visible = false
        end
    end)
end

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25,0,1,0)
    btn.BackgroundColor3 = name == currentTab and Theme.ItemBg or Theme.SectionBg
    btn.Text = string.upper(name)
    btn.TextColor3 = name == currentTab and Theme.TextPrimary or Theme.TextSecondary
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = TabBar

    local bottomLine = Instance.new("Frame")
    bottomLine.Size = UDim2.new(1,0,0,2)
    bottomLine.Position = UDim2.new(0,0,1,-2)
    bottomLine.BackgroundColor3 = name == currentTab and Theme.Accent or Theme.Border
    bottomLine.BorderSizePixel = 0
    bottomLine.Parent = btn
    if name == currentTab then table.insert(accentColorElements, {obj = bottomLine, type = "BackgroundColor3"}) end

    tabBtns[name] = {btn = btn, line = bottomLine}

    btn.MouseButton1Click:Connect(function()
        if currentTab == name then return end
        if tabBtns[currentTab] then
            TweenService:Create(tabBtns[currentTab].btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SectionBg, TextColor3 = Theme.TextSecondary}):Play()
            TweenService:Create(tabBtns[currentTab].line, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Border}):Play()
        end
        currentTab = name
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ItemBg, TextColor3 = Theme.TextPrimary}):Play()
        TweenService:Create(bottomLine, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        loadCosmeticGrid()
    end)
end

createTab("Skin")
createTab("Wrap")
createTab("Charm")
createTab("Finisher")

_G.OpenSkinMenu = function(wep)
    currentWeapon = wep
    WepLabel.Text = string.upper(wep)
    SkinContainer.Visible = true
    TweenService:Create(LoadoutContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(-1,0,0,55)}):Play()
    SkinContainer.Position = UDim2.new(1,0,0,55)
    TweenService:Create(SkinContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,55)}):Play()
    if currentTab ~= "Skin" then
        if tabBtns[currentTab] then
            TweenService:Create(tabBtns[currentTab].btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SectionBg, TextColor3 = Theme.TextSecondary}):Play()
            TweenService:Create(tabBtns[currentTab].line, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Border}):Play()
        end
        currentTab = "Skin"
        TweenService:Create(tabBtns["Skin"].btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ItemBg, TextColor3 = Theme.TextPrimary}):Play()
        TweenService:Create(tabBtns["Skin"].line, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    end
    loadCosmeticGrid()
end

BackBtn.MouseButton1Click:Connect(function()
    TweenService:Create(SkinContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1,0,0,55)}):Play()
    TweenService:Create(LoadoutContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,55)}):Play()
    task.wait(0.4)
    SkinContainer.Visible = false
    if activeModel then activeModel:Destroy() activeModel = nil end
    currentLoadId = currentLoadId + 1
    _G._phantomLoadId = currentLoadId
end)

ApplyBtn.MouseButton1Click:Connect(function()
    if currentWeapon and currentCosmetic then
        local ogS = ApplyBtn.Size
        local ogP = ApplyBtn.Position
        TweenService:Create(ApplyBtn, TweenInfo.new(0.1), {Size = UDim2.new(0,196,0,40), Position = UDim2.new(1,-208,0.5,-20)}):Play()
        task.wait(0.1)
        TweenService:Create(ApplyBtn, TweenInfo.new(0.15), {Size = ogS, Position = ogP}):Play()
        applyCosmeticLogic(currentWeapon, currentCosmetic, currentTab)
        if autoSaveEnabled and currentConfigName ~= "" then
            task.spawn(function() saveConfig(currentConfigName) end)
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if spinning then rotY = rotY + math.rad(25 * dt) end
    curX = curX + (rotX - curX) * 0.12
    curY = curY + (rotY - curY) * 0.12
    if activeModel then
        pcall(function() activeModel:PivotTo(CFrame.new(0,0,0) * CFrame.Angles(curX, curY, 0)) end)
    end
end)

local MiniGui = Instance.new("ScreenGui")
MiniGui.Name = "PhantomMiniButton"
MiniGui.Parent = CoreGui
MiniGui.Enabled = true
MiniGui.IgnoreGuiInset = true
MiniGui.ResetOnSpawn = false
MiniGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MiniButton = Instance.new("ImageButton")
MiniButton.Size = UDim2.new(0, 46, 0, 46)
MiniButton.Position = UDim2.new(0, 20, 0.5, -23)
MiniButton.BackgroundColor3 = Theme.Background
MiniButton.BackgroundTransparency = 0.1
MiniButton.Image = "rbxassetid://112964043447417"
MiniButton.ImageColor3 = Theme.Accent
MiniButton.ScaleType = Enum.ScaleType.Fit
MiniButton.AutoButtonColor = false
MiniButton.Active = true
MiniButton.Parent = MiniGui
table.insert(accentColorElements, {obj = MiniButton, type = "ImageColor3"})

local MBCorner = Instance.new("UICorner")
MBCorner.CornerRadius = UDim.new(0,23)
MBCorner.Parent = MiniButton

local MBStroke = Instance.new("UIStroke")
MBStroke.Color = Theme.Accent
MBStroke.Thickness = 2
MBStroke.Transparency = 0.3
MBStroke.Parent = MiniButton
table.insert(accentColorElements, {obj = MBStroke, type = "Color"})

local miniDragging = false
local miniDragStart = nil
local miniStartPos = nil
local miniWasDragged = false

MiniButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniWasDragged = false
        miniDragStart = input.Position
        miniStartPos = MiniButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - miniDragStart
        if delta.Magnitude > 5 then miniWasDragged = true end
        MiniButton.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
    end
end)

MiniButton.MouseButton1Click:Connect(function()
    if miniWasDragged then
        miniWasDragged = false
        return
    end
    isMenuOpen = not isMenuOpen
    if isMenuOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = onScreenPos}):Play()
    else
        if settingsOpen then
            settingsOpen = false
            SettingsPanel.Position = UDim2.new(0,0,0,-720)
            TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.TextSecondary}):Play()
            if autoSaveEnabled and currentConfigName ~= "" then saveConfig(currentConfigName) end
            saveSettings()
        end
        local hide = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = offScreenPos})
        hide:Play()
        hide.Completed:Connect(function()
            if not isMenuOpen then MainFrame.Visible = false end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        isMenuOpen = not isMenuOpen
        if isMenuOpen then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = onScreenPos}):Play()
        else
            if settingsOpen then
                settingsOpen = false
                SettingsPanel.Position = UDim2.new(0,0,0,-720)
                TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {ImageColor3 = Theme.TextSecondary}):Play()
                if autoSaveEnabled and currentConfigName ~= "" then saveConfig(currentConfigName) end
                saveSettings()
            end
            local hide = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = offScreenPos})
            hide:Play()
            hide.Completed:Connect(function()
                if not isMenuOpen then MainFrame.Visible = false end
            end)
        end
    end
end)

task.spawn(function()
    task.wait(1)
    loadSettings()
    syncPickerToAccent()
    setAutoLoad(autoLoadEnabled)
    setAutoSave(autoSaveEnabled)
    if currentConfigName ~= "" then
        CfgNameBox.Text = currentConfigName
        DropText.Text = currentConfigName
        DropText.TextColor3 = Theme.TextPrimary
        DropIconLbl.Text = string.upper(string.sub(currentConfigName, 1, 1))
    end
    if autoLoadEnabled and currentConfigName ~= "" then
        task.wait(0.5)
        loadConfig(currentConfigName)
        syncPickerToAccent()
    end
end)
