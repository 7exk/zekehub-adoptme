--!nolint
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE_URL = "https://raw.githubusercontent.com/TON_PSEUDO/zekehub-autonomous/main/"

local function FetchModule(relativePath)
    if type(isfile) == "function" and isfile("ZekeHub_Local/" .. relativePath) then
        return readfile("ZekeHub_Local/" .. relativePath)
    end
    return game:HttpGet(BASE_URL .. relativePath)
end

local BootStrap
local okBoot, bootErr = pcall(function()
    local code = FetchModule("UILib/BootstrapLoader.lua")
    BootStrap = loadstring(code)()
end)

if not okBoot or not BootStrap then
    warn("[ZekeHub] Échec du chargement de BootstrapLoader : " .. tostring(bootErr))
    return
end

task.spawn(function()
    BootStrap:SetStatus("Initializing environment...")
    BootStrap:SetProgress(15)
    task.wait(0.25)

    local executorName = identifyexecutor and identifyexecutor() or "Standard Executor"
    BootStrap:SetDetails("Executor: " .. tostring(executorName))
    BootStrap:SetDetails("PlaceId: " .. tostring(game.PlaceId))
    BootStrap:SetProgress(40)
    task.wait(0.25)

    BootStrap:SetStatus("Bypassing key check (Autonomous Mode)...")
    BootStrap:SetDetails("Auth: Local Master Access Granted")
    BootStrap:SetProgress(65)
    task.wait(0.3)

    BootStrap:SetStatus("Loading Adopt Me module...")
    BootStrap:SetProgress(85)

    local okGame, gameErr = pcall(function()
        local gameCode = FetchModule("Games/AdoptMe.lua")
        local runGame = loadstring(gameCode)
        if not runGame then
            error("Syntax error in Games/AdoptMe.lua")
        end
        runGame(BootStrap)
    end)

    if okGame then
        BootStrap:Finish("Loaded")
    else
        BootStrap:Fail("Failed to load game script", tostring(gameErr))
    end
end)
